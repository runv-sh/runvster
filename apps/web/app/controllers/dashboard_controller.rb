class DashboardController < ApplicationController
  before_action :require_authentication!

  def show
    @recent_posts = current_user.posts.recent_first.limit(5)
    @recent_invitations = invitations_scope.recent_first.limit(8)
    @pending_invitations_count = invitations_scope.pending.count
    @notifications = current_user.notifications.recent_first.limit(6)
    @open_reports_count = current_user.admin? ? ModerationCase.open.count : current_user.reported_moderation_cases.open.count

    return unless current_user.admin?

    @member_count = User.member.count
    @admin_count = User.admin.count
    @total_posts_count = Post.count
    @comment_count = Comment.count
    @vote_count = Vote.count
    @latest_members = User.order(created_at: :desc).limit(8)
    @recent_platform_posts = Post.recent_first.limit(8)
    @moderation_cases = ModerationCase.recent_first.limit(6)
    @admin_actions = AdminAction.recent_first.limit(8)
    @tags = Tag.featured.limit(10)
  end

  private

  def invitations_scope
    current_user.admin? ? Invitation.includes(:inviter, :invitee) : current_user.sent_invitations.includes(:invitee)
  end
end
