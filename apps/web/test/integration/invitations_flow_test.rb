require 'test_helper'

class InvitationsFlowTest < ActionDispatch::IntegrationTest
  test 'eligible verified member can send an invitation' do
    user = create_user(verified: true, created_at: 45.days.ago)
    sign_in_as(user)

    assert_difference('Invitation.count', 1) do
      post invitations_path, params: { invitation: { recipient_email: 'nova-pessoa@example.com' } }
    end

    assert_redirected_to dashboard_path
    assert_equal 'nova-pessoa@example.com', Invitation.order(:created_at).last.recipient_email
  end

  test 'unverified member is redirected before sending invites' do
    user = create_user(verified: false, created_at: 45.days.ago)
    sign_in_as(user)

    assert_no_difference('Invitation.count') do
      post invitations_path, params: { invitation: { recipient_email: 'bloqueado@example.com' } }
    end

    assert_redirected_to edit_account_path
  end

  test 'sign up requires a valid invite after the first account exists' do
    create_bootstrap_admin

    get sign_up_path

    assert_response :forbidden
    assert_match(/convite/i, response.body)
  end
end
