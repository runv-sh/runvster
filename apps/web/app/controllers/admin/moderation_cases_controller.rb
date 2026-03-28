module Admin
  class ModerationCasesController < ApplicationController
    before_action :require_staff!

    def index
      @moderation_cases = ModerationCase.includes(:reporter, :resolver, :reportable).recent_first
    end

    def update
      moderation_case = ModerationCase.find(params[:id])
      moderation_case.resolve_with_action!(
        staff: current_user,
        status: resolution_params[:status],
        resolution_note: resolution_params[:resolution_note],
        moderation_action: resolution_params[:moderation_action],
        suspension_hours: resolution_params[:suspension_hours]
      )
      AdminAction.create!(
        admin: current_user,
        action_type: "moderation_case_updated",
        target_type: "ModerationCase",
        target_id: moderation_case.id,
        details: "Caso atualizado para #{moderation_case.status}."
      )
      Notification.notify_moderation_resolved!(moderation_case)

      redirect_to admin_moderation_cases_path, notice: "Caso de moderacao atualizado."
    rescue ActiveRecord::RecordInvalid => e
      redirect_to admin_moderation_cases_path, alert: e.record.errors.full_messages.to_sentence
    end

    private

    def resolution_params
      params.expect(moderation_case: [ :status, :resolution_note, :moderation_action, :suspension_hours ])
    end
  end
end
