class NotificationsController < ApplicationController
  before_action :require_authentication!

  def index
    @notifications = current_user.notifications.recent_first.limit(50)
  end

  def update
    notification = current_user.notifications.find(params[:id])
    notification.update!(read_at: Time.current)
    redirect_back fallback_location: notifications_path, notice: "Notificacao marcada como lida."
  end
end
