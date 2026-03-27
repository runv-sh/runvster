class UsersController < ApplicationController
  before_action :redirect_authenticated_user, only: %i[new create]
  before_action :set_user, only: :show
  before_action :set_required_invitation, only: %i[new create]

  def new
    return render_invite_required if invite_required_without_valid_token?

    @user = User.new
    @user.email = @invitation.recipient_email if @invitation.present?
  end

  def create
    return render_invite_required if invite_required_without_valid_token?

    @user = User.new(user_params)
    @user.email = @invitation.recipient_email if @invitation.present?

    if @user.save
      @invitation&.mark_as_accepted!(@user)
      start_session_for(@user)
      redirect_to dashboard_path, notice: "Conta criada. Bora publicar."
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

  def set_required_invitation
    return if User.count.zero?

    @invitation = Invitation.find_by(token: params[:invite].to_s)
  end

  def set_user
    @user = User.find_by!(username: params[:username].to_s.downcase)
  end

  def redirect_authenticated_user
    redirect_to root_path, notice: "Sua conta ja esta ativa." if authenticated?
  end

  def invite_required_without_valid_token?
    return false if User.count.zero?

    @invitation.blank? || !@invitation.active?
  end

  def render_invite_required
    render :invite_required, status: :forbidden
  end
end
