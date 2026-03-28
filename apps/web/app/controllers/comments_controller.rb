class CommentsController < ApplicationController
  before_action :require_authentication!
  before_action :require_verified_email_for_posting!, only: :create
  before_action :set_post
  before_action :set_comment, only: %i[edit update destroy]
  before_action :authorize_comment_editor!, only: %i[edit update destroy]

  def create
    @comment = @post.comments.build(comment_params.merge(user: current_user))

    if @comment.save
      redirect_to post_path(@post, anchor: "comment-#{@comment.id}"), notice: "Comentario publicado."
    else
      redirect_to post_path(@post), alert: @comment.errors.full_messages.to_sentence
    end
  end

  def edit
  end

  def update
    if @comment.update(comment_params.except(:parent_id))
      redirect_to post_path(@post, anchor: "comment-#{@comment.id}"), notice: "Comentario atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy!
    redirect_to post_path(@post), notice: "Comentario excluido."
  end

  private

  def set_post
    @post = Post.find(params[:post_id])
    return unless @post.hidden? && !current_user&.staff?

    redirect_to root_path, alert: "Esse post foi ocultado pela moderacao."
  end

  def set_comment
    @comment = @post.all_comments.find(params[:id])
  end

  def comment_params
    params.expect(comment: [ :body, :parent_id ])
  end

  def authorize_comment_editor!
    return if @comment.editable_by?(current_user)

    redirect_to post_path(@post), alert: "Voce nao pode editar esse comentario."
  end
end
