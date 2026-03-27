module Admin
  class PostsController < ApplicationController
    before_action :require_admin!

    def index
      @posts = Post.includes(:user, :tags).recent_first
    end

    def update
      post = Post.find(params[:id])
      post.assign_attributes(post_params)
      post.assign_tag_names(params.dig(:post, :tag_names))

      if post.save
        AdminAction.create!(
          admin: current_user,
          action_type: "post_updated",
          target_type: "Post",
          target_id: post.id,
          details: "Post atualizado: #{post.title}."
        )
        redirect_to admin_posts_path, notice: "Post atualizado."
      else
        redirect_to admin_posts_path, alert: post.errors.full_messages.to_sentence
      end
    end

    def destroy
      post = Post.find(params[:id])
      title = post.title
      post.destroy!

      AdminAction.create!(
        admin: current_user,
        action_type: "post_deleted",
        target_type: "Post",
        target_id: post.id,
        details: "Post removido: #{title}."
      )
      redirect_to admin_posts_path, notice: "Post excluido."
    end

    private

    def post_params
      params.expect(post: [ :title, :url, :body ])
    end
  end
end
