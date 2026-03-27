class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :resume_session

  helper_method :authenticated?, :current_user

  private

  def authenticated?
    current_user.present?
  end

  def current_user
    Current.user
  end

  def require_authentication!
    return if authenticated?

    redirect_to sign_in_path, alert: "Entre para continuar."
  end

  def require_admin!
    return if authenticated? && current_user.admin?

    redirect_to dashboard_path, alert: "Area restrita a administradores."
  end

  def resume_session
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id].present?
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
