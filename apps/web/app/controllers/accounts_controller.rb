class AccountsController < ApplicationController
  before_action :require_authentication!

  def edit
    @user = current_user
  end

  def update
    @user = current_user

    if @user.update(account_params)
      notice = "Perfil atualizado."

      if @user.saved_change_to_email?
        token = @user.generate_email_confirmation_token!
        UserMailer.with(user: @user, token: token).email_confirmation_email.deliver_later
        notice = "Perfil atualizado. Confirmamos o novo email com um link enviado para #{@user.email}."
      end

      redirect_to edit_account_path, notice:
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def account_params
    params.expect(user: [
      :username,
      :email,
      :bio,
      :notify_on_comments,
      :notify_on_replies,
      :notify_on_invites,
      :notify_on_moderation,
      :digest_frequency
    ])
  end
end
