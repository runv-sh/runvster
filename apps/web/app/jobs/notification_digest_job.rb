class NotificationDigestJob < ApplicationJob
  queue_as :default

  def perform(frequency)
    User.public_send(frequency).where.not(email_verified_at: nil).find_each do |user|
      summary = NotificationDigestSummary.new(user:, frequency:)
      next if summary.empty?

      UserMailer.with(user:, summary:, frequency:).notification_digest_email.deliver_now
      user.update!(last_digest_sent_at: Time.current)
    end
  end
end
