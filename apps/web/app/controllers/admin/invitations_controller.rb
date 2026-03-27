module Admin
  class InvitationsController < ApplicationController
    before_action :require_admin!

    def index
      @invitations = Invitation.includes(:inviter, :invitee).recent_first
    end

    def update
      invitation = Invitation.find(params[:id])
      invitation.revoke!(note: params.dig(:invitation, :acceptance_note))

      AdminAction.create!(
        admin: current_user,
        action_type: "invitation_revoked",
        target_type: "Invitation",
        target_id: invitation.id,
        details: "Convite para #{invitation.recipient_email} revogado."
      )
      redirect_to admin_invitations_path, notice: "Convite revogado."
    end

    def destroy
      invitation = Invitation.find(params[:id])
      recipient_email = invitation.recipient_email
      invitation.destroy!

      AdminAction.create!(
        admin: current_user,
        action_type: "invitation_deleted",
        target_type: "Invitation",
        target_id: invitation.id,
        details: "Convite excluido para #{recipient_email}."
      )
      redirect_to admin_invitations_path, notice: "Convite excluido."
    end
  end
end
