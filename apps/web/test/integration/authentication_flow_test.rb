require 'test_helper'

class AuthenticationFlowTest < ActionDispatch::IntegrationTest
  test 'user signs in and reaches the dashboard' do
    user = create_user

    post session_path, params: { session: { email: user.email, password: default_password } }

    assert_redirected_to dashboard_path
    follow_redirect!
    assert_response :success
    assert_match(/painel|dashboard/i, response.body)
  end

  test 'restricted user cannot sign in' do
    user = create_user(account_state: :banned)

    post session_path, params: { session: { email: user.email, password: default_password } }

    assert_response :unprocessable_entity
    assert_match(/banida/i, response.body)
  end
end
