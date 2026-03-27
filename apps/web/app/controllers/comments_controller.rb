class CommentsController < ApplicationController
  before_action :require_authentication!
  before_action :set_post

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to post_path(@post, anchor: "comment-#{@comment.id}"), notice: "Comentario publicado."
    else
      redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence
    end
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
  end

  def comment_params
    params.expect(comment: [ :body, :parent_id ])
  end
end
