class PasswordResetsController < ApplicationController
  before_action :set_user_from_token, only: %i[edit update]

  def new
  end

  def create
    user = User.find_by(email: params.dig(:password_reset, :email).to_s.strip.downcase)

    if user.present?
      token = user.generate_password_reset_token!
      UserMailer.with(user:, token:).password_reset_email.deliver_later
    end

    redirect_to sign_in_path, notice: "Se esse email existir, voce recebera um link para redefinir a senha."
  end

  def edit
  end

  def update
    if @user.update(password_reset_params)
      @user.clear_password_reset!
      redirect_to sign_in_path, notice: "Senha redefinida. Voce ja pode entrar."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_reset_params
    params.expect(user: %i[password password_confirmation])
  end

  def set_user_from_token
    @user = User.find_by(password_reset_token: params[:token].to_s)

    return if @user&.password_reset_token_valid?

    redirect_to new_password_reset_path, alert: "Link de redefinicao invalido ou expirado."
  end
end
