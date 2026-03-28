class ApiTokensController < ApplicationController
  before_action :require_authentication!

  def create
    token_name = params.dig(:api_token, :name).to_s
    expires_at = parsed_expiration
    token = ApiToken.issue!(user: current_user, name: token_name, expires_at:)

    session[:last_created_api_token] = token.plain_text_token
    redirect_back fallback_location: dashboard_path, notice: "Token de API criado. Copie agora porque ele nao sera exibido novamente."
  rescue ActiveRecord::RecordInvalid => e
    redirect_back fallback_location: dashboard_path, alert: e.record.errors.full_messages.to_sentence
  end

  def destroy
    token = current_user.api_tokens.find(params[:id])
    token.revoke!
    redirect_back fallback_location: dashboard_path, notice: "Token revogado."
  end

  private

  def parsed_expiration
    days = params.dig(:api_token, :expires_in_days).to_i
    return if days <= 0

    days.days.from_now
  end
end
