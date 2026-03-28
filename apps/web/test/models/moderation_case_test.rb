require 'test_helper'

class ModerationCaseTest < ActiveSupport::TestCase
  test 'resolving a case can suspend a reported user' do
    admin = create_user(role: :admin)
    reporter = create_user
    reported = create_user(username: 'reported_user')
    moderation_case = ModerationCase.create!(
      reporter: reporter,
      reportable: reported,
      reason: 'Abuso repetido',
      details: 'Volume alto de conteudo inadequado.'
    )

    moderation_case.resolve_with_action!(
      staff: admin,
      status: 'resolved',
      resolution_note: 'Conta suspensa para revisao.',
      moderation_action: 'suspend_user',
      suspension_hours: 24
    )

    assert moderation_case.reload.resolved?
    assert_equal admin, moderation_case.resolver
    assert reported.reload.suspended?
    assert reported.suspended_until.future?
  end
end
