class NotificationDigestSummary
  MAX_NOTIFICATIONS = 12
  MAX_POSTS = 6

  attr_reader :user, :frequency, :window_start

  def initialize(user:, frequency:, window_start: nil)
    @user = user
    @frequency = frequency
    @window_start = window_start || user.digest_window_start_for(frequency)
  end

  def notifications_scope
    user.notifications.unread.where(created_at: window_start..Time.current).recent_first
  end

  def new_posts_scope
    Post.visible
      .includes(:user, :tags)
      .where(posts: { created_at: window_start..Time.current })
      .where.not(user_id: user.id)
      .order(created_at: :desc)
  end

  def notifications
    @notifications ||= notifications_scope.limit(MAX_NOTIFICATIONS).to_a
  end

  def new_posts
    @new_posts ||= new_posts_scope.limit(MAX_POSTS).to_a
  end

  def notifications_count
    @notifications_count ||= notifications_scope.count
  end

  def new_posts_count
    @new_posts_count ||= new_posts_scope.count
  end

  def any?
    notifications_count.positive? || new_posts_count.positive?
  end

  def empty?
    !any?
  end

  def label
    frequency == "weekly" ? "semanal" : "diario"
  end
end
