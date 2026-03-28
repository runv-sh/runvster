module Admin
  class CommunitySettingsController < ApplicationController
    before_action :require_admin!

    def update
      settings = CommunitySetting.current

      if settings.update(settings_params)
        redirect_to admin_invitations_path, notice: "Politicas da comunidade atualizadas."
      else
        redirect_to admin_invitations_path, alert: settings.errors.full_messages.to_sentence
      end
    end

    private

    def settings_params
      params.expect(community_setting: [
        :member_invite_limit,
        :member_invite_unlock_days,
        :invite_expiration_days,
        :posts_per_hour,
        :comments_per_ten_minutes,
        :reports_per_hour,
        :require_email_verification_for_posting,
        :require_email_verification_for_invites
      ])
    end
  end
end
