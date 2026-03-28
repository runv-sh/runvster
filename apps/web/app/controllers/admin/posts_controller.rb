module Admin
  class PostsController < ApplicationController
    before_action :require_staff!
    before_action :require_admin!, only: :destroy

    def index
      @posts = Post.includes(:user, :tags, :hidden_by).order(created_at: :desc)
    end

    def update
      post = Post.find(params[:id])
      post.assign_attributes(post_params)
      post.assign_tag_names(params.dig(:post, :tag_names))

      if post.save
        apply_moderation_action(post)
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

    def apply_moderation_action(post)
      case params.dig(:post, :moderation_action)
      when "hide"
        post.hide!(by: current_user, reason: params.dig(:post, :moderation_note)) unless post.hidden?
        Notification.notify_content_moderated!(post, actor: current_user, note: params.dig(:post, :moderation_note).to_s)
      when "restore"
        post.restore! if post.hidden?
        Notification.notify_content_moderated!(post, actor: current_user, note: params.dig(:post, :moderation_note).to_s)
      end
    end
  end
end
