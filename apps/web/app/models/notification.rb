class Notification < ApplicationRecord
  belongs_to :recipient, class_name: "User"
  belongs_to :actor, class_name: "User", optional: true

  validates :kind, :record_type, :record_id, :message, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :unread, -> { where(read_at: nil) }

  def self.notify_comment!(comment)
    if comment.post.user != comment.user
      create!(
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

    create!(
      recipient: comment.parent.user,
      actor: comment.user,
      kind: "reply_created",
      record_type: "Comment",
      record_id: comment.id,
      message: "@#{comment.user.username} respondeu ao seu comentario em \"#{comment.post.title}\"."
    )
  end

  def self.notify_invitation_accepted!(invitation)
    create!(
      recipient: invitation.inviter,
      actor: invitation.invitee,
      kind: "invitation_accepted",
      record_type: "Invitation",
      record_id: invitation.id,
      message: "#{invitation.invitee.username} aceitou o convite enviado para #{invitation.recipient_email}."
    )
  end

  def self.notify_moderation_report!(moderation_case)
    User.admin.find_each do |admin|
      create!(
        recipient: admin,
        actor: moderation_case.reporter,
        kind: "moderation_reported",
        record_type: "ModerationCase",
        record_id: moderation_case.id,
        message: "Novo reporte de moderacao para #{moderation_case.reportable_type.downcase}."
      )
    end
  end

  def self.notify_moderation_resolved!(moderation_case)
    create!(
      recipient: moderation_case.reporter,
      actor: moderation_case.resolver,
      kind: "moderation_resolved",
      record_type: "ModerationCase",
      record_id: moderation_case.id,
      message: "Seu reporte de moderacao foi atualizado para #{moderation_case.status.humanize.downcase}."
    )
  end
end
