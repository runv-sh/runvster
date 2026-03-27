module Admin
  class ModerationCasesController < ApplicationController
    before_action :require_admin!

    def index
      @moderation_cases = ModerationCase.includes(:reporter, :resolver).recent_first
    end

    def update
      moderation_case = ModerationCase.find(params[:id])
      moderation_case.resolve!(
        admin: current_user,
        status: resolution_params[:status],
        resolution_note: resolution_params[:resolution_note]
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
      params.expect(moderation_case: [ :status, :resolution_note ])
    end
  end
end
