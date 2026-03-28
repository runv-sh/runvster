module Api
  module V1
    class SessionsController < BaseController
      include Concerns::Serialization

      def show
        return render_error("not_authenticated", "Nenhuma sessao ativa.", :unauthorized) unless authenticated?

        render json: { user: serialize_user(current_user, include_private: true) }
      end

      def create
        user = User.find_by(email: session_params[:email].to_s.strip.downcase)
        user&.reactivate_if_needed!

        unless user&.authenticate(session_params[:password])
          return render_error("invalid_credentials", "Email ou senha invalidos.", :unprocessable_entity)
        end

        if user.restriction_active?
          return render_error("account_restricted", user.restriction_message, :forbidden)
        end

        start_session_for(user)
        render json: { user: serialize_user(user, include_private: true) }, status: :created
      end

      def destroy
        end_session
        head :no_content
      end

      private

      def session_params
        params.expect(session: %i[email password])
      end
    end
  end
end
