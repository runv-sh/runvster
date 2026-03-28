class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :resume_session

  helper_method :authenticated?, :current_user, :staff_member?

  private

  def authenticated?
    current_user.present?
  end

  def current_user
    Current.user
  end

  def staff_member?
    current_user&.staff?
  end

  def require_authentication!
    return if authenticated?

    redirect_to sign_in_path, alert: "Entre para continuar."
  end

  def require_staff!
    return if authenticated? && current_user.staff?

    redirect_to dashboard_path, alert: "Area restrita a moderadores e administradores."
  end

  def require_admin!
    return if authenticated? && current_user.admin?

    redirect_to dashboard_path, alert: "Area restrita a administradores."
  end

  def require_verified_email_for_posting!
    return unless authenticated?
    return unless CommunitySetting.current.require_email_verification_for_posting
    return if current_user.email_verified?

    redirect_to edit_account_path, alert: "Confirme seu email antes de publicar ou comentar."
  end

  def require_verified_email_for_invites!
    return unless authenticated?
    return unless CommunitySetting.current.require_email_verification_for_invites
    return if current_user.email_verified?

    redirect_to edit_account_path, alert: "Confirme seu email antes de enviar convites."
  end

  def resume_session
    return unless session[:user_id].present?

    Current.user = User.find_by(id: session[:user_id])
    Current.user&.reactivate_if_needed!
    return unless Current.user&.restriction_active?

    flash[:alert] = Current.user.restriction_message
    end_session
  end

  def start_session_for(user)
    session[:user_id] = user.id
    Current.user = user
  end

  def end_session
    session.delete(:user_id)
    Current.user = nil
  end
end
