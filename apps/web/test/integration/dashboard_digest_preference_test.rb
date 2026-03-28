require 'test_helper'

class DashboardDigestPreferenceTest < ActionDispatch::IntegrationTest
  test 'verified user can enable weekly digest from the dashboard' do
    user = create_user(verified: true)
    sign_in_as(user)

    patch dashboard_digest_path, params: { digest: { enabled: true } }

    assert_redirected_to dashboard_path
    assert user.reload.weekly_digest_enabled?
  end

  test 'unverified user cannot enable weekly digest from the dashboard' do
    user = create_user(verified: false)
    sign_in_as(user)

    patch dashboard_digest_path, params: { digest: { enabled: true } }

    assert_redirected_to dashboard_path
    assert_equal 'off', user.reload.digest_frequency
  end

  test 'user can disable weekly digest from the dashboard' do
    user = create_user(verified: true)
    user.update!(digest_frequency: 'weekly')
    sign_in_as(user)

    patch dashboard_digest_path, params: { digest: { enabled: false } }

    assert_redirected_to dashboard_path
    assert_equal 'off', user.reload.digest_frequency
  end
end
