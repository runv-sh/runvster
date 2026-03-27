class UsersController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]
  before_action :set_user, only: :show

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      start_session_for(@user)
      redirect_to root_path, notice: "Conta criada. Bora publicar."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @posts = @user.posts.recent_first
  end

  private

  def user_params
    params.expect(user: %i[username email bio password password_confirmation])
  end

  def set_user
    @user = User.find_by!(username: params[:username].to_s.downcase)
  end

  def redirect_authenticated_user
    redirect_to root_path, notice: "Sua conta ja esta ativa." if authenticated?
  end
end
