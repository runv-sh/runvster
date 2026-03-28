class Comment < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user
  belongs_to :parent, class_name: "Comment", optional: true, counter_cache: :replies_count
  belongs_to :hidden_by, class_name: "User", optional: true

  has_many :replies, -> { visible.order(created_at: :asc) }, class_name: "Comment", foreign_key: :parent_id, inverse_of: :parent
  has_many :all_replies, -> { order(created_at: :asc) }, class_name: "Comment", foreign_key: :parent_id, dependent: :destroy, inverse_of: :parent
  has_many :moderation_cases, as: :reportable, dependent: :destroy

  before_validation :normalize_body
  before_save :stamp_edit_timestamp, if: :will_save_change_to_body?
  after_create_commit :notify_relevant_people

  validates :body, presence: true, length: { maximum: 3000 }
  validate :respect_comment_rate_limit, on: :create
  validate :prevent_duplicate_recent_comments, on: :create

  scope :root_level, -> { where(parent_id: nil) }
  scope :visible, -> { where(hidden_at: nil) }
  scope :recent_first, -> { order(created_at: :desc) }
  scope :chronological, -> { order(created_at: :asc) }

  def hidden?
    hidden_at.present?
  end

  def hide!(by:, reason:)
    transaction do
      hide_single_comment!(by:, reason:) unless hidden?
      all_replies.each { |reply| reply.hide!(by:, reason:) unless reply.hidden? }
    end
  end

  def restore!
    transaction do
      restore_single_comment! if hidden?
      all_replies.each(&:restore!)
    end
  end

  def editable_by?(actor)
    actor.present? && (actor == user || actor.staff?)
  end

  private

  def normalize_body
    self.body = body.to_s.strip.presence
  end

  def stamp_edit_timestamp
    self.edited_at = Time.current if persisted?
  end

  def notify_relevant_people
    Notification.notify_comment!(self)
  end

  def respect_comment_rate_limit
    return if user.blank?
    return unless user.comments.where("created_at >= ?", 10.minutes.ago).count >= CommunitySetting.current.comments_per_ten_minutes

    errors.add(:base, "Voce comentou muitas vezes em pouco tempo. Espere alguns minutos antes de responder de novo.")
  end

  def prevent_duplicate_recent_comments
    return if user.blank?
    return unless user.comments.where(post_id: post_id).where("created_at >= ?", 30.minutes.ago).where("LOWER(body) = ?", body.to_s.downcase).exists?

    errors.add(:body, "parece duplicado de um comentario recente seu neste post.")
  end

  def hide_single_comment!(by:, reason:)
    update!(
      hidden_at: Time.current,
      hidden_by: by,
      hidden_reason: reason.presence || "Ocultado pela moderacao."
    )
    Post.decrement_counter(:comments_count, post_id) if post.comments_count.positive?
    self.class.decrement_counter(:replies_count, parent_id) if parent_id.present? && parent.replies_count.positive?
  end

  def restore_single_comment!
    update!(
      hidden_at: nil,
      hidden_by: nil,
      hidden_reason: nil
    )
    Post.increment_counter(:comments_count, post_id)
    self.class.increment_counter(:replies_count, parent_id) if parent_id.present?
  end
end
