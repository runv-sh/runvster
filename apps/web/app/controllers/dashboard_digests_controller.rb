class DashboardDigestsController < ApplicationController
  before_action :require_authentication!

  def update
    enabled = ActiveModel::Type::Boolean.new.cast(digest_params[:enabled])

    if enabled && !current_user.email_verified?
      return redirect_to dashboard_path, alert: "Confirme seu email antes de ativar o resumo semanal."
    end

    current_user.update!(digest_frequency: enabled ? "weekly" : "off")
    redirect_to dashboard_path, notice: enabled ? "Resumo semanal ativado." : "Resumo semanal desativado."
  end

  private

  def digest_params
    params.expect(digest: [ :enabled ])
  end
end
