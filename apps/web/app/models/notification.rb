class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true

  validates :kind, :record_type, :record_id, :message, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def self.notify_comment!(comment)
    if comment.post.user != comment.user
      create_for!(
        recipient: comment.post.user,
        actor: comment.user,
        kind: "comment_created",
        record_type: "Comment",
        record_id: comment.id,
        message: "@#{comment.user.username} comentou no seu post \"#{comment.post.title}\"."
      )
    end

    return unless comment.parent.present?
    return if comment.parent.user == comment.user || comment.parent.user == comment.post.user

    create_for!(
      recipient: comment.parent.user,
      actor: comment.user,
      kind: "reply_created",
      record_type: "Comment",
      record_id: comment.id,
      message: "@#{comment.user.username} respondeu ao seu comentario em \"#{comment.post.title}\"."
    )
  end

  def self.notify_invitation_accepted!(invitation)
    create_for!(
      recipient: invitation.inviter,
      actor: invitation.invitee,
      kind: "invitation_accepted",
      record_type: "Invitation",
      record_id: invitation.id,
      message: "#{invitation.invitee.username} aceitou o convite enviado para #{invitation.recipient_email}."
    )
  end

  def self.notify_moderation_report!(moderation_case)
    User.staff.find_each do |staff_member|
      create_for!(
        recipient: staff_member,
        actor: moderation_case.reporter,
        kind: "moderation_reported",
        record_type: "ModerationCase",
        record_id: moderation_case.id,
        message: "Novo reporte de moderacao para #{moderation_case.reportable_type.downcase}."
      )
    end
  end

  def self.notify_moderation_resolved!(moderation_case)
    create_for!(
      recipient: moderation_case.reporter,
      actor: moderation_case.resolver,
      kind: "moderation_resolved",
      record_type: "ModerationCase",
      record_id: moderation_case.id,
        message: "Seu reporte de moderacao foi atualizado para #{moderation_case.status.humanize.downcase}."
    )
  end

  def self.notify_content_moderated!(record, actor:, note:)
    owner = record.respond_to?(:user) ? record.user : record
    return if owner.blank? || owner == actor

    action = record.respond_to?(:hidden?) && record.hidden? ? "foi ocultado" : "foi restaurado"
    create_for!(
      recipient: owner,
      actor: actor,
      kind: "content_moderated",
      record_type: record.class.name,
      record_id: record.id,
      message: "Seu #{record.class.name.downcase} #{action} pela moderacao. #{note}".strip
    )
  end

  def self.notify_account_state_changed!(user, actor:)
    create_for!(
      recipient: user,
      actor: actor,
      kind: "account_moderated",
      record_type: "User",
      record_id: user.id,
      message: "Sua conta agora esta com status #{user.account_state.humanize.downcase}."
    )
  end

  def self.create_for!(recipient:, actor:, kind:, record_type:, record_id:, message:)
    return unless recipient.prefers_notification?(kind)
    return if actor.present? && actor == recipient
    return if unread.exists?(recipient:, kind:, record_type:, record_id:)

    create!(
      recipient:,
      actor:,
      kind:,
      record_type:,
      record_id:,
      message:
    )
  end
end
