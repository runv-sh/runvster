require 'test_helper'

class NotificationDigestJobTest < ActiveSupport::TestCase
  test 'weekly digest sends when there are community updates' do
    User.update_all(digest_frequency: 'off', last_digest_sent_at: Time.current)
    user = create_user(verified: true)
    user.update!(digest_frequency: 'weekly')
    author = create_user(username: 'digest_author')
    create_post(user: author, title: 'Novidade semanal para o digest')

    with_weekly_scope_for(user) do
      assert_difference('ActionMailer::Base.deliveries.size', 1) do
        NotificationDigestJob.perform_now('weekly')
      end
    end

    email = ActionMailer::Base.deliveries.last
    assert_match(/Novidade semanal para o digest/, email.body.encoded)
    assert user.reload.last_digest_sent_at.present?
  end

  test 'weekly digest is skipped when there is nothing new' do
    User.update_all(digest_frequency: 'off', last_digest_sent_at: Time.current)
    Notification.update_all(created_at: 2.weeks.ago, read_at: Time.current) if Notification.exists?
    Post.update_all(created_at: 2.weeks.ago, updated_at: 2.weeks.ago) if Post.exists?

    user = create_user(verified: true)
    user.update!(digest_frequency: 'weekly', last_digest_sent_at: Time.current)

    summary = NotificationDigestSummary.new(user: user, frequency: 'weekly')
    assert summary.empty?

    with_weekly_scope_for(user) do
      assert_no_difference('ActionMailer::Base.deliveries.size') do
        NotificationDigestJob.perform_now('weekly')
      end
    end
  end

  private

  def with_weekly_scope_for(user)
    user_id = user.id
    eigenclass = class << User; self; end
    original_weekly = User.method(:weekly)
    eigenclass.send(:define_method, :weekly) { where(id: user_id) }
    yield
  ensure
    eigenclass.send(:define_method, :weekly) { original_weekly.call }
  end
end
