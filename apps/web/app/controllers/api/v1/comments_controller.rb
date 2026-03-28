module Api
  module V1
    class CommentsController < BaseController
      include Concerns::Serialization

      before_action :require_authentication!
      before_action :require_verified_email_for_posting!, only: :create
      before_action :set_post
      before_action :set_comment, only: %i[update destroy]
      before_action :authorize_comment_editor!, only: %i[update destroy]

      def create
        comment = @post.comments.build(comment_params.merge(user: current_user))

        if comment.save
          render json: { comment: serialize_comment(comment, current_user:) }, status: :created
        else
          render_validation_errors(comment)
        end
      end

      def update
        if @comment.update(comment_params.except(:parent_id))
          render json: { comment: serialize_comment(@comment, current_user:) }
        else
          render_validation_errors(@comment)
        end
      end

      def destroy
        @comment.destroy!
        head :no_content
      end

      private

      def set_post
        @post = Post.find(params[:post_id])
        return unless @post.hidden? && !current_user&.staff?

        render_error("post_hidden", "Esse post foi ocultado pela moderacao.", :forbidden)
      end

      def set_comment
        @comment = @post.all_comments.find(params[:id])
      end

      def comment_params
        params.expect(comment: %i[body parent_id])
      end

      def authorize_comment_editor!
        return if @comment.editable_by?(current_user)

        render_error("forbidden", "Voce nao pode editar esse comentario.", :forbidden)
      end
    end
  end
end
