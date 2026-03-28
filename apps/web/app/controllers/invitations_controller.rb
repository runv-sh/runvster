class InvitationsController < ApplicationController
  before_action :require_authentication!
  before_action :require_verified_email_for_invites!

  def create
    @invitation = current_user.sent_invitations.build(invitation_params)

    if @invitation.save
      @invitation.deliver_invite_email!
      redirect_to dashboard_path, notice: "Convite enviado para #{@invitation.recipient_email}."
    else
      redirect_to dashboard_path, alert: @invitation.errors.full_messages.to_sentence
    end
  end

  private

  def invitation_params
    params.expect(invitation: [ :recipient_email ])
  end
end
