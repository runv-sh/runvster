class InvitationMailer < ApplicationMailer
  def invite_email
    @invitation = params[:invitation]
    @inviter = @invitation.inviter
    @signup_url = sign_up_url(invite: @invitation.token)

    mail(
      to: @invitation.recipient_email,
      subject: "Seu acesso ao Runvster esta pronto"
    )
  end
end
