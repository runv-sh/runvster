module Admin
  class InvitationsController < ApplicationController
    before_action :require_admin!

    def index
      @invitations = Invitation.includes(:inviter, :invitee).recent_first
      @community_setting = CommunitySetting.current
    end

    def update
      invitation = Invitation.find(params[:id])
      operation = params.dig(:invitation, :operation).to_s

      case operation
      when "resend"
        invitation.deliver_invite_email! if invitation.resendable?
      when "remind"
        invitation.deliver_invite_email!(reminder: true) if invitation.remindable?
      when "extend"
        invitation.extend_expiration! if invitation.active?
      else
        invitation.revoke!(note: params.dig(:invitation, :acceptance_note)) if invitation.active?
      end

      AdminAction.create!(
        admin: current_user,
        action_type: "invitation_updated",
        target_type: "Invitation",
        target_id: invitation.id,
        details: "Convite para #{invitation.recipient_email} atualizado com operacao #{operation.presence || 'revoke'}."
      )
      redirect_to admin_invitations_path, notice: "Convite atualizado."
    end

    def bulk_update
      invitations = Invitation.where(id: Array(params[:invitation_ids]))
      operation = params[:operation].to_s

      invitations.each do |invitation|
        case operation
        when "resend"
          invitation.deliver_invite_email! if invitation.resendable?
        when "remind"
          invitation.deliver_invite_email!(reminder: true) if invitation.remindable?
        when "extend"
          invitation.extend_expiration! if invitation.active?
        when "revoke"
          invitation.revoke!(note: params[:bulk_note]) if invitation.active?
        end
      end

      AdminAction.create!(
        admin: current_user,
        action_type: "invitation_bulk_updated",
        target_type: "Invitation",
        target_id: nil,
        details: "Lote de #{invitations.count} convites atualizado com operacao #{operation}."
      )

      redirect_to admin_invitations_path, notice: "Operacao em lote aplicada."
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
