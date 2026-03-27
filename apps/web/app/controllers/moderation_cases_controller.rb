class ModerationCasesController < ApplicationController
  before_action :require_authentication!

  def create
    moderation_case = current_user.reported_moderation_cases.build(moderation_case_params)

    if moderation_case.save
      redirect_back fallback_location: root_path, notice: "Reporte enviado para a moderacao."
    else
      redirect_back fallback_location: root_path, alert: moderation_case.errors.full_messages.to_sentence
    end
  end

  private

  def moderation_case_params
    params.expect(moderation_case: [ :reason, :details, :reportable_type, :reportable_id ])
  end
end
