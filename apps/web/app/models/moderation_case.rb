class ModerationCase < ApplicationRecord
  belongs_to :reportable, polymorphic: true
  belongs_to :reporter, class_name: "User"
  belongs_to :resolver, class_name: "User", optional: true

  enum :status, { open: "open", reviewing: "reviewing", resolved: "resolved", dismissed: "dismissed" }, default: :open, validate: true

  before_validation :normalize_text
  after_create_commit :notify_admins

  validates :reason, presence: true, length: { maximum: 120 }
  validates :details, length: { maximum: 1500 }
  validate :respect_report_rate_limit, on: :create

  scope :recent_first, -> { order(created_at: :desc) }

  def resolve!(admin:, status:, resolution_note:)
    update!(
      resolver: admin,
      status: status,
      resolution_note: resolution_note,
      resolved_at: Time.current
    )
  end

  def resolve_with_action!(staff:, status:, resolution_note:, moderation_action:, suspension_hours:)
    transaction do
      apply_moderation_action!(staff:, moderation_action:, resolution_note:, suspension_hours:)
      resolve!(admin: staff, status:, resolution_note:)
    end
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

  def respect_report_rate_limit
    return if reporter.blank?
    return unless reporter.reported_moderation_cases.where("created_at >= ?", 1.hour.ago).count >= CommunitySetting.current.reports_per_hour

    errors.add(:base, "Voce enviou muitos reportes em pouco tempo. Aguarde antes de abrir outro caso.")
  end

  def apply_moderation_action!(staff:, moderation_action:, resolution_note:, suspension_hours:)
    note = resolution_note.presence || reason

    case moderation_action
    when "hide_content"
      reportable.hide!(by: staff, reason: note) if reportable.respond_to?(:hide!)
    when "restore_content"
      reportable.restore! if reportable.respond_to?(:restore!)
    when "suspend_user"
      return unless reportable.is_a?(User)

      until_at = suspension_hours.to_i.positive? ? suspension_hours.to_i.hours.from_now : nil
      reportable.suspend!(note:, until_at:)
      Notification.notify_account_state_changed!(reportable, actor: staff)
    when "ban_user"
      return unless reportable.is_a?(User)

      reportable.ban!(note:)
      Notification.notify_account_state_changed!(reportable, actor: staff)
    when "reactivate_user"
      return unless reportable.is_a?(User)

      reportable.reactivate!(note:)
      Notification.notify_account_state_changed!(reportable, actor: staff)
    end

    Notification.notify_content_moderated!(reportable, actor: staff, note:) if %w[hide_content restore_content].include?(moderation_action)
  end
end
