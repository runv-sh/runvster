ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

Dir[Rails.root.join('test/support/**/*.rb')].sort.each { |file| require file }

ActiveJob::Base.queue_adapter = :test

class ActiveSupport::TestCase
  parallelize(workers: 1)
  self.use_transactional_tests = true

  include ActiveJob::TestHelper
  include TestDataHelper

  setup do
    Current.reset if defined?(Current)
    ActionMailer::Base.deliveries.clear
    clear_enqueued_jobs
    clear_performed_jobs

    CommunitySetting.current.update!(
      member_invite_limit: 5,
      member_invite_unlock_days: 30,
      invite_expiration_days: 7,
      posts_per_hour: 10,
      comments_per_ten_minutes: 10,
      reports_per_hour: 10,
      require_email_verification_for_posting: false,
      require_email_verification_for_invites: true
    )
  end
end

class ActionDispatch::IntegrationTest
  include TestDataHelper
end
