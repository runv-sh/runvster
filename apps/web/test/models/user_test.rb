require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'first user becomes admin automatically' do
    [AdminAction, Notification, ModerationCase, Invitation, ApiToken, Tagging, Comment, Vote, Post, Tag, User].each(&:delete_all)

    user = User.create!(
      username: 'primeiro_admin',
      email: 'primeiro@example.com',
      password: default_password,
      password_confirmation: default_password,
      bio: 'Primeira conta',
      email_verified_at: Time.current
    )

    assert user.reload.admin?
  end
end
