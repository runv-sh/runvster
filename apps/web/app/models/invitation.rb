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

  def mark_as_accepted!(user)
    update!(invitee: user, accepted_at: Time.current, acceptance_note: "Conta criada via convite.")
    Notification.notify_invitation_accepted!(self)
  end

  def revoke!(note: nil)
    update!(revoked_at: Time.current, acceptance_note: note.presence || acceptance_note)
  end

  private

  def normalize_recipient_email
    self.recipient_email = recipient_email.to_s.strip.downcase
  end

  def ensure_token
    self.token ||= SecureRandom.urlsafe_base64(24)
  end

  def set_default_expiration
    self.expires_at ||= 14.days.from_now
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
end
