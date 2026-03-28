require 'test_helper'

class AdminUsersFlowTest < ActionDispatch::IntegrationTest
  test 'admin can promote another user to admin' do
    admin = create_user(role: :admin)
    member = create_user
    sign_in_as(admin)

    patch admin_user_path(member), params: {
      user: {
        username: member.username,
        email: member.email,
        bio: member.bio,
        role: 'admin',
        account_state: member.account_state,
        moderation_note: 'Promovido para operar o espaco.'
      }
    }

    assert_redirected_to admin_users_path
    assert member.reload.admin?
  end

  test 'admin cannot delete the own account from the panel' do
    admin = create_user(role: :admin, username: 'solo_admin', email: 'solo@example.com', ensure_admin: false)
    sign_in_as(admin)

    assert_no_difference('User.count') do
      delete admin_user_path(admin)
    end

    assert_redirected_to admin_users_path
    assert_match(/propria conta/i, flash[:alert].to_s)
  end
end
