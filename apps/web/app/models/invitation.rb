class Invitation < ApplicationRecord
  belongs_to :inviter, class_name: "User"
  belongs_to :invitee, class_name: "User", optional: true

  before_validation :normalize_recipient_email
  before_validation :ensure_token, on: :create

  validates :recipient_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :token, presence: true, uniqueness: true
  validate :inviter_can_send_invites
  validate :recipient_email_has_no_pending_invitation, on: :create
  validate :recipient_email_has_no_existing_account, on: :create
  validate :respect_invitation_rate_limit, on: :create

  scope :pending, lambda {
    where(accepted_at: nil, revoked_at: nil)
      .where("expires_at IS NULL OR expires_at > ?", Time.current)
  }
  scope :accepted, -> { where.not(accepted_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }

  before_create :set_default_expiration

  def accepted?
    accepted_at.present?
  end

  def pending?
    !accepted? && !expired? && !revoked?
  end

  def expired?
    expires_at.present? && expires_at.past?
  end

  def revoked?
    revoked_at.present?
  end

  def active?
    !accepted? && !expired? && !revoked?
  end

  def resendable?
    pending?
  end

  def remindable?
    pending? && (reminder_sent_at.blank? || reminder_sent_at <= 12.hours.ago)
  end

  def mark_as_accepted!(user)
    update!(invitee: user, accepted_at: Time.current, acceptance_note: "Conta criada via convite.")
    Notification.notify_invitation_accepted!(self)
  end

  def revoke!(note: nil)
    update!(revoked_at: Time.current, acceptance_note: note.presence || acceptance_note)
  end

  def deliver_invite_email!(reminder: false)
    touch_attributes = {
      sent_count: sent_count + 1,
      last_sent_at: Time.current
    }
    touch_attributes[:reminder_sent_at] = Time.current if reminder
    update!(touch_attributes)

    mailer = InvitationMailer.with(invitation: self)
    (reminder ? mailer.reminder_email : mailer.invite_email).deliver_later
  end

  def extend_expiration!
    update!(expires_at: CommunitySetting.current.invite_expiration_days.days.from_now)
  end

  private

  def normalize_recipient_email
    self.recipient_email = recipient_email.to_s.strip.downcase
  end

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_default_expiration
    self.expires_at ||= CommunitySetting.current.invite_expiration_days.days.from_now
  end

  def inviter_can_send_invites
    return if inviter.blank? || inviter.can_send_invite?

    errors.add(:base, "Esse usuario nao pode emitir novos convites agora.")
  end

  def recipient_email_has_no_pending_invitation
    return if recipient_email.blank?
    return unless self.class.pending.where(recipient_email: recipient_email).where.not(id: id).exists?

    errors.add(:recipient_email, "ja possui um convite pendente.")
  end

  def recipient_email_has_no_existing_account
    return unless User.exists?(email: recipient_email)

    errors.add(:recipient_email, "ja esta associado a uma conta existente.")
  end

  def respect_invitation_rate_limit
    return if inviter.blank? || inviter.admin?
    return unless inviter.sent_invitations.where("created_at >= ?", 1.day.ago).count >= inviter.invite_limit

    errors.add(:base, "A cota atual de convites para este periodo ja foi utilizada.")
  end
end
