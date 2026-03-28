class NotificationDigestJob < ApplicationJob
  queue_as :default

  def perform(frequency)
    User.public_send(frequency).where.not(email_verified_at: nil).find_each do |user|
      notifications = user.notifications.unread.where("created_at >= ?", user.digest_window_start).recent_first.limit(20)
      next if notifications.empty?

      UserMailer.with(user:, notifications:, frequency:).notification_digest_email.deliver_now
      user.update!(last_digest_sent_at: Time.current)
    end
  end
end
