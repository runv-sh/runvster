class UserMailer < ApplicationMailer
  def email_confirmation_email
    @user = params[:user]
    @confirmation_url = email_confirmation_url(token: params[:token])

    mail(
      to: @user.email,
      subject: "Confirme seu email no Runvster"
    )
  end

  def password_reset_email
    @user = params[:user]
    @reset_url = edit_password_reset_url(params[:token])

    mail(
      to: @user.email,
      subject: "Redefina sua senha no Runvster"
    )
  end

  def notification_digest_email
    @user = params[:user]
    @notifications = params[:notifications]
    @frequency = params[:frequency]

    mail(
      to: @user.email,
      subject: "Seu resumo #{@frequency == 'weekly' ? 'semanal' : 'diario'} do Runvster"
    )
  end
end
