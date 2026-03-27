class User < ApplicationRecord
  STANDARD_INVITE_LIMIT = 5
  INVITES_UNLOCK_AFTER = 1.month

  has_secure_password

  has_many :posts, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :sent_invitations, class_name: "Invitation", foreign_key: :inviter_id, dependent: :destroy, inverse_of: :inviter
  has_many :accepted_invitations, class_name: "Invitation", foreign_key: :invitee_id, dependent: :nullify, inverse_of: :invitee
  has_many :notifications, foreign_key: :recipient_id, dependent: :destroy, inverse_of: :recipient
  has_many :reported_moderation_cases, class_name: "ModerationCase", foreign_key: :reporter_id, dependent: :destroy, inverse_of: :reporter
  has_many :resolved_moderation_cases, class_name: "ModerationCase", foreign_key: :resolver_id, dependent: :nullify, inverse_of: :resolver
  has_many :admin_actions, foreign_key: :admin_id, dependent: :destroy, inverse_of: :admin

  enum :role, { member: "member", moderator: "moderator", admin: "admin" }, default: :member, validate: true

  before_validation :normalize_identity_fields
  before_create :promote_first_user_to_admin

  validates :email, presence: true, uniqueness: true
  validates :username,
    presence: true,
    uniqueness: true,
    length: { in: 3..24 },
    format: { with: /\A[a-z0-9_]+\z/, message: "use apenas letras minúsculas, números e _" }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :bio, length: { maximum: 280 }

  def to_param
    username
  end

  def invite_eligible?
    admin? || created_at.present? && created_at <= INVITES_UNLOCK_AFTER.ago
  end

  def invite_limit
    return Float::INFINITY if admin?
    return 0 unless invite_eligible?

    STANDARD_INVITE_LIMIT
  end

  def invites_used_count
    sent_invitations.count
  end

  def available_invites_count
    return nil if admin?

    [invite_limit - invites_used_count, 0].max
  end

  def can_send_invite?
    admin? || available_invites_count.to_i.positive?
  end

  def invite_unlocks_at
    created_at.to_time + INVITES_UNLOCK_AFTER if created_at.present?
  end

  def unread_notifications_count
    notifications.unread.count
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
end
