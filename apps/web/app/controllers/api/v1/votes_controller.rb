module Api
  module V1
    class VotesController < BaseController
      include Concerns::Serialization

      before_action :require_authentication!
      before_action :set_post

      def create
        vote = current_user.votes.find_or_initialize_by(post: @post)
        vote.value = normalized_value

        if vote.save
          render json: { post: serialize_post(@post.reload, current_user:) }, status: :created
        else
          render_validation_errors(vote)
        end
      end

      def update
        vote = current_user.votes.find_by!(post: @post)

        if vote.update(value: normalized_value)
          render json: { post: serialize_post(@post.reload, current_user:) }
        else
          render_validation_errors(vote)
        end
      end

      def destroy
        current_user.votes.find_by!(post: @post).destroy!
        render json: { post: serialize_post(@post.reload, current_user:) }
      end

      private

      def set_post
        @post = Post.visible.find(params[:post_id])
      end

      def normalized_value
        params[:value].to_i.positive? ? 1 : -1
      end
    end
  end
end
