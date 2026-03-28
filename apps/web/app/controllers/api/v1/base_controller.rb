module Api
  module V1
    class BaseController < ApplicationController
      skip_forgery_protection
      prepend_before_action :authenticate_api_token
      before_action :ensure_json_request

      rescue_from ActiveRecord::RecordNotFound, with: :render_not_found
      rescue_from ActionController::ParameterMissing, with: :render_bad_request

      private

      def ensure_json_request
        request.format = :json
      end

      def authenticate_api_token
        raw_token = bearer_token
        return if raw_token.blank?

        token = ApiToken.authenticate(raw_token)
        return render_error("invalid_api_token", "Token de API invalido, expirado ou revogado.", :unauthorized) if token.blank?

        Current.user = token.user
        token.touch_last_used!
      end

      def bearer_token
        header = request.authorization.to_s
        return if header.blank?

        scheme, token = header.split(" ", 2)
        return token if scheme.to_s.casecmp("Bearer").zero?

        nil
      end

      def require_authentication!
        return if authenticated?

        render_error("authentication_required", "Entre para continuar.", :unauthorized)
      end

      def require_staff!
        return if authenticated? && current_user.staff?

        render_error("staff_required", "Area restrita a moderadores e administradores.", :forbidden)
      end

      def require_admin!
        return if authenticated? && current_user.admin?

        render_error("admin_required", "Area restrita a administradores.", :forbidden)
      end

      def require_verified_email_for_posting!
        return unless authenticated?
        return unless CommunitySetting.current.require_email_verification_for_posting
        return if current_user.email_verified?

        render_error("email_verification_required", "Confirme seu email antes de publicar ou comentar.", :forbidden)
      end

      def require_verified_email_for_invites!
        return unless authenticated?
        return unless CommunitySetting.current.require_email_verification_for_invites
        return if current_user.email_verified?

        render_error("email_verification_required", "Confirme seu email antes de enviar convites.", :forbidden)
      end

      def render_error(code, message, status, details: nil)
        payload = { error: { code:, message: } }
        payload[:error][:details] = details if details.present?
        render json: payload, status:
      end

      def render_validation_errors(record)
        render_error(
          "validation_failed",
          "Os dados enviados sao invalidos.",
          :unprocessable_entity,
          details: record.errors.to_hash(true)
        )
      end

      def render_not_found
        render_error("not_found", "Recurso nao encontrado.", :not_found)
      end

      def render_bad_request(exception)
        render_error("bad_request", exception.message, :bad_request)
      end

      def pagination_meta(scope, page:, page_size:)
        total_count = scope.count(:all)
        {
          page:,
          page_size:,
          total_count:,
          has_previous_page: page > 1,
          has_next_page: (page * page_size) < total_count
        }
      end
    end
  end
end
