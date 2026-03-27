class ModerationCase < ApplicationRecord
  belongs_to :reportable, polymorphic: true
  belongs_to :reporter, class_name: "User"
  belongs_to :resolver, class_name: "User", optional: true

  enum :status, { open: "open", reviewing: "reviewing", resolved: "resolved", dismissed: "dismissed" }, default: :open, validate: true

  before_validation :normalize_text
  after_create_commit :notify_admins

  validates :reason, presence: true, length: { maximum: 120 }
  validates :details, length: { maximum: 1500 }

  scope :recent_first, -> { order(created_at: :desc) }

  def resolve!(admin:, status:, resolution_note:)
    update!(
      resolver: admin,
      status: status,
      resolution_note: resolution_note,
      resolved_at: Time.current
    )
  end

  private

  def normalize_text
    self.reason = reason.to_s.strip
    self.details = details.to_s.strip.presence
    self.resolution_note = resolution_note.to_s.strip.presence
  end

  def notify_admins
    Notification.notify_moderation_report!(self)
  end
end
