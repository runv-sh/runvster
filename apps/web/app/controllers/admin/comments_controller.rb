module Admin
  class CommentsController < ApplicationController
    before_action :require_staff!
    before_action :require_admin!, only: :destroy

    def index
      @comments = Comment.includes(:user, :post, :hidden_by).recent_first
    end

    def update
      comment = Comment.find(params[:id])

      if comment.update(params.expect(comment: [ :body ]))
        apply_moderation_action(comment)
        AdminAction.create!(
          admin: current_user,
          action_type: "comment_updated",
          target_type: "Comment",
          target_id: comment.id,
          details: "Comentario #{comment.id} atualizado no post #{comment.post_id}."
        )
        redirect_to admin_comments_path, notice: "Comentario atualizado."
      else
        redirect_to admin_comments_path, alert: comment.errors.full_messages.to_sentence
      end
    end

    def destroy
      comment = Comment.find(params[:id])
      comment_id = comment.id
      post_id = comment.post_id
      comment.destroy!

      AdminAction.create!(
        admin: current_user,
        action_type: "comment_deleted",
        target_type: "Comment",
        target_id: comment_id,
        details: "Comentario #{comment_id} removido do post #{post_id}."
      )
      redirect_to admin_comments_path, notice: "Comentario excluido."
    end

    private

    def apply_moderation_action(comment)
      case params.dig(:comment, :moderation_action)
      when "hide"
        comment.hide!(by: current_user, reason: params.dig(:comment, :moderation_note)) unless comment.hidden?
        Notification.notify_content_moderated!(comment, actor: current_user, note: params.dig(:comment, :moderation_note).to_s)
      when "restore"
        comment.restore! if comment.hidden?
        Notification.notify_content_moderated!(comment, actor: current_user, note: params.dig(:comment, :moderation_note).to_s)
      end
    end
  end
end
