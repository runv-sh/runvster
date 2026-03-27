class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count

  has_many :replies, -> { order(created_at: :asc) }, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :moderation_cases, as: :reportable, dependent: :destroy

  before_validation :normalize_body
  after_create_commit :notify_relevant_people

  validates :body, presence: true, length: { maximum: 3000 }

  scope :root_level, -> { where(parent_id: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  private

  def normalize_body
    self.body = body.to_s.strip.presence
  end

  def notify_relevant_people
    Notification.notify_comment!(self)
  end
end
