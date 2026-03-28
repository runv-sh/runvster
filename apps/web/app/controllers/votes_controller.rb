class VotesController < ApplicationController
  before_action :require_authentication!
  before_action :set_post

  def create
    vote = current_user.votes.find_or_initialize_by(post: @post)
    vote.value = normalized_value

    if vote.save
      redirect_back fallback_location: post_path(@post), notice: "Voto registrado."
    else
      redirect_back fallback_location: post_path(@post), alert: vote.errors.full_messages.to_sentence
    end
  end

  def update
    vote = current_user.votes.find_by!(post: @post)

    if vote.update(value: normalized_value)
      redirect_back fallback_location: post_path(@post), notice: "Voto atualizado."
    else
      redirect_back fallback_location: post_path(@post), alert: vote.errors.full_messages.to_sentence
    end
  end

  def destroy
    current_user.votes.find_by!(post: @post).destroy!
    redirect_back fallback_location: post_path(@post), notice: "Voto removido."
  end

  private

  def set_post
    @post = Post.visible.find(params[:post_id])
  end

  def normalized_value
    params[:value].to_i.positive? ? 1 : -1
  end
end
