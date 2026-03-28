module Api
  module V1
    class NotificationsController < BaseController
      include Concerns::Serialization

      before_action :require_authentication!

      def index
        notifications = current_user.notifications.recent_first.limit(50)
        render json: {
          notifications: notifications.map { |notification| serialize_notification(notification) },
          meta: {
            unread_count: current_user.notifications.unread.count
          }
        }
      end

      def update
        notification = current_user.notifications.find(params[:id])
        notification.update!(read_at: Time.current)
        render json: { notification: serialize_notification(notification) }
      end
    end
  end
end
