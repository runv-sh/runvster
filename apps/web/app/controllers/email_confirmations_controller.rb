class EmailConfirmationsController < ApplicationController
  before_action :require_authentication!, only: :create

  def show
    user = User.find_by(email_confirmation_token: params[:token].to_s)

    if user.present?
      user.confirm_email!
      redirect_to edit_account_path, notice: "Email confirmado."
    else
      redirect_to sign_in_path, alert: "Link de confirmacao invalido ou expirado."
    end
  end

  def create
    token = current_user.generate_email_confirmation_token!
    UserMailer.with(user: current_user, token: token).email_confirmation_email.deliver_later
    redirect_to edit_account_path, notice: "Reenviamos o link de confirmacao."
  end
end
