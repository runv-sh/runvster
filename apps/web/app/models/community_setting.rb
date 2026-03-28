class CommunitySetting < ApplicationRecord
  validates :member_invite_limit, numericality: { greater_than_or_equal_to: 0 }
  validates :member_invite_unlock_days, :invite_expiration_days, numericality: { greater_than: 0 }
  validates :posts_per_hour, :comments_per_ten_minutes, :reports_per_hour, numericality: { greater_than: 0 }

  def self.current
    first_or_create!
  end
end
