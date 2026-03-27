class AdminAction < ApplicationRecord
  belongs_to :admin, class_name: "User"

  validates :action_type, :target_type, presence: true

  scope :recent_first, -> { order(created_at: :desc) }
end
