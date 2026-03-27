module Admin
  class CommentsController < ApplicationController
    before_action :require_admin!

    def index
      @comments = Comment.includes(:user, :post).recent_first
    end

    def update
      comment = Comment.find(params[:id])

      if comment.update(params.expect(comment: [ :body ]))
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
  end
end
