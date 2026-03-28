class User < ApplicationRecord
  STANDARD_INVITE_LIMIT = 5
  INVITES_UNLOCK_AFTER = 1.month

  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :api_tokens, dependent: :destroy
  has_many :hidden_posts, class_name: "Post", foreign_key: :hidden_by_id, dependent: :nullify, inverse_of: :hidden_by
  has_many :hidden_comments, class_name: "Comment", foreign_key: :hidden_by_id, dependent: :nullify, inverse_of: :hidden_by
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :inviter_id, dependent: :destroy, inverse_of: :inviter
  has_many :accepted_invitations, class_name: "Invitation", foreign_key: :invitee_id, dependent: :nullify, inverse_of: :invitee
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient
  has_many :reported_moderation_cases, class_name: "ModerationCase", foreign_key: :reporter_id, dependent: :destroy, inverse_of: :reporter
  has_many :resolved_moderation_cases, class_name: "ModerationCase", foreign_key: :resolver_id, dependent: :nullify, inverse_of: :resolver
  has_many :admin_actions, foreign_key: :admin_id, dependent: :destroy, inverse_of: :admin

  enum :role, { member: "member", moderator: "moderator", admin: "admin" }, default: :member, validate: true
  enum :account_state, { active: "active", suspended: "suspended", banned: "banned" }, default: :active, validate: true
  enum :digest_frequency, { off: "off", daily: "daily", weekly: "weekly" }, default: :off, validate: true

  before_validation :normalize_identity_fields
  before_create :promote_first_user_to_admin
  before_save :reset_email_verification, if: -> { persisted? && will_save_change_to_email? }

  validates :email, presence: true, uniqueness: true
  validates :username,
    presence: true,
    uniqueness: true,
    length: { in: 3..24 },
    format: { with: /\A[a-z0-9_]+\z/, message: "use apenas letras minúsculas, números e _" }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :bio, length: { maximum: 280 }

  scope :staff, -> { where(role: %w[moderator admin]) }

  def to_param
    username
  end

  def staff?
    moderator? || admin?
  end

  def email_verified?
    email_verified_at.present?
  end

  def confirm_email!
    update!(
      email_verified_at: Time.current,
      email_confirmation_token: nil,
      email_confirmation_sent_at: nil
    )
  end

  def generate_email_confirmation_token!
    token = SecureRandom.urlsafe_base64(24)
    update!(
      email_confirmation_token: token,
      email_confirmation_sent_at: Time.current
    )
    token
  end

  def generate_password_reset_token!
    token = SecureRandom.urlsafe_base64(24)
    update!(
      password_reset_token: token,
      password_reset_sent_at: Time.current
    )
    token
  end

  def clear_password_reset!
    update!(
      password_reset_token: nil,
      password_reset_sent_at: nil
    )
  end

  def password_reset_token_valid?
    password_reset_token.present? && password_reset_sent_at.present? && password_reset_sent_at >= 2.hours.ago
  end

  def restriction_active?
    banned? || suspended? && (suspended_until.blank? || suspended_until.future?)
  end

  def restriction_message
    return if active? || suspended? && suspended_until.present? && suspended_until.past?

    if banned?
      "Sua conta foi banida. Entre em contato com a moderacao caso precise de revisao."
    elsif suspended? && suspended_until.present?
      "Sua conta esta suspensa ate #{I18n.l(suspended_until, format: :long)}."
    elsif suspended?
      "Sua conta esta suspensa por tempo indeterminado."
    end
  end

  def reactivate_if_needed!
    return unless suspended? && suspended_until.present? && suspended_until.past?

    reactivate!(note: "Suspensao encerrada automaticamente.")
  end

  def suspend!(note:, until_at:)
    update!(
      account_state: "suspended",
      suspended_until: until_at,
      moderation_note: note.presence || moderation_note
    )
  end

  def ban!(note:)
    update!(
      account_state: "banned",
      suspended_until: nil,
      moderation_note: note.presence || moderation_note
    )
  end

  def reactivate!(note: nil)
    update!(
      account_state: "active",
      suspended_until: nil,
      moderation_note: note.presence || moderation_note
    )
  end

  def invite_eligible?
    admin? || created_at.present? && created_at <= invite_unlock_interval.ago
  end

  def invite_limit
    return Float::INFINITY if admin?
    return 0 unless invite_eligible?

    CommunitySetting.current.member_invite_limit
  end

  def invites_used_count
    sent_invitations.count
  end

  def available_invites_count
    return nil if admin?

    [invite_limit - invites_used_count, 0].max
  end

  def can_send_invite?
    return false if restriction_active?
    return false if CommunitySetting.current.require_email_verification_for_invites && !email_verified?

    admin? || available_invites_count.to_i.positive?
  end

  def invite_unlocks_at
    created_at.to_time + invite_unlock_interval if created_at.present?
  end

  def unread_notifications_count
    notifications.unread.count
  end

  def active_api_tokens_count
    api_tokens.active.count
  end

  def prefers_notification?(kind)
    case kind
    when "comment_created"
      notify_on_comments?
    when "reply_created"
      notify_on_replies?
    when "invitation_accepted"
      notify_on_invites?
    else
      notify_on_moderation?
    end
  end

  def digest_window_start
    last_digest_sent_at || (weekly? ? 1.week.ago : 1.day.ago)
  end

  def digest_window_start_for(frequency)
    last_digest_sent_at || (frequency.to_s == "weekly" ? 1.week.ago : 1.day.ago)
  end

  def weekly_digest_enabled?
    digest_frequency == "weekly"
  end

  private

  def normalize_identity_fields
    self.email = email.to_s.strip.downcase
    self.username = username.to_s.strip.downcase
    self.bio = bio.to_s.squish.presence
  end

  def promote_first_user_to_admin
    self.role = "admin" if self.class.count.zero?
  end

  def reset_email_verification
    self.email_verified_at = nil
    self.email_confirmation_token = nil
    self.email_confirmation_sent_at = nil
  end

  def invite_unlock_interval
    CommunitySetting.current.member_invite_unlock_days.days
  end
end
