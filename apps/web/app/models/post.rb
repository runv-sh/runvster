class Post < ApplicationRecord
  MAX_TAGS = 3

  belongs_to :user, counter_cache: true
  belongs_to :hidden_by, class_name: "User", optional: true

  has_many :comments, -> { visible.includes(:user, replies: :user).chronological }, inverse_of: :post
  has_many :all_comments, -> { includes(:user).chronological }, class_name: "Comment", dependent: :destroy, inverse_of: :post
  has_many :votes, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, -> { order(name: :asc) }, through: :taggings
  has_many :moderation_cases, as: :reportable, dependent: :destroy

  before_validation :normalize_fields
  before_save :reset_thumbnail_preview, if: :will_save_change_to_url?
  before_save :stamp_edit_timestamp, if: :persisted_changes_for_edit?
  after_commit :queue_thumbnail_refresh, on: %i[create update], if: :saved_change_to_url?

  validates :title, presence: true, length: { in: 8..140 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :body, length: { maximum: 5000 }

  validate :url_or_body_present
  validate :tag_count_within_limits
  validate :respect_post_rate_limit, on: :create
  validate :prevent_duplicate_recent_posts, on: :create

  scope :with_feed_associations, -> { includes(:user, :tags) }
  scope :visible, -> { where(hidden_at: nil) }
  scope :recent_first, -> { visible.with_feed_associations.order(created_at: :desc) }
  scope :link_posts, -> { visible.where.not(url: [nil, ""]) }
  scope :discussion_posts, -> { visible.where(url: [nil, ""]).where.not(body: [nil, ""]) }
  scope :links_first, -> { link_posts.recent_first }
  scope :discussion_first, -> { discussion_posts.recent_first }
  scope :top_first, lambda {
    visible.with_feed_associations
      .order(
        Arel.sql(
          "(
            (LEAST(posts.score, 40) * 6) +
            (LEAST(posts.comments_count, 20) * 3) +
            (LEAST(posts.votes_count, 30) * 1.5) +
            GREATEST(0, 72 - (EXTRACT(EPOCH FROM (NOW() - posts.created_at)) / 3600.0)) -
            (GREATEST(posts.votes_count - ABS(posts.score), 0) * 2)
          ) DESC,
          posts.created_at DESC"
        )
      )
  }
  scope :matching_query, lambda { |query|
    sanitized_query = "%#{sanitize_sql_like(query.to_s.strip.downcase)}%"
    left_outer_joins(:tags, :user)
      .where(
        "LOWER(posts.title) LIKE :query OR LOWER(COALESCE(posts.body, '')) LIKE :query OR LOWER(tags.name) LIKE :query OR LOWER(users.username) LIKE :query",
        query: sanitized_query
      )
      .distinct
  }
  scope :tagged_with, ->(slug) { joins(:tags).where(tags: { slug: slug.to_s.downcase }).distinct }
  scope :authored_by, ->(username) { joins(:user).where(users: { username: username.to_s.downcase }).distinct }

  def tag_list
    tags.map(&:name).join(", ")
  end

  def assign_tag_names(raw_names)
    normalized_names = raw_names.to_s.split(",").map do |value|
      value.strip.downcase.gsub(/[^a-z0-9\- ]/, "").tr(" ", "-").gsub(/-{2,}/, "-").gsub(/\A-|-+\z/, "")
    end.reject(&:blank?).uniq.first(MAX_TAGS)

    self.tags = normalized_names.map do |name|
      Tag.find_or_initialize_by(slug: name).tap do |tag|
        tag.name = name
      end
    end
  end

  def link_post?
    url.present?
  end

  def score_for(user)
    return 0 if user.blank?

    votes.find_by(user: user)&.value.to_i
  end

  def hidden?
    hidden_at.present?
  end

  def hide!(by:, reason:)
    update!(
      hidden_at: Time.current,
      hidden_by: by,
      hidden_reason: reason.presence || "Ocultado pela moderacao."
    )
  end

  def restore!
    update!(
      hidden_at: nil,
      hidden_by: nil,
      hidden_reason: nil
    )
  end

  def editable_by?(actor)
    actor.present? && (actor == user || actor.staff?)
  end

  def display_host
    URI.parse(url).host&.sub(/\Awww\./, "") if url.present?
  rescue URI::InvalidURIError
    nil
  end

  def social_description
    body.presence || [
      "Link compartilhado por @#{user.username} no Runvster",
      display_host.presence
    ].compact.join(" · ")
  end

  def thumbnail?
    thumbnail_url.present?
  end

  private

  def normalize_fields
    self.title = title.to_s.squish
    self.url = url.to_s.strip.presence
    self.body = body.to_s.strip.presence
  end

  def url_or_body_present
    return if url.present? || body.present?

    errors.add(:base, "Adicione um link ou escreva um contexto para o post.")
  end

  def tag_count_within_limits
    return if tags.size.between?(1, MAX_TAGS)

    errors.add(:tags, "escolha entre 1 e #{MAX_TAGS} tags")
  end

  def persisted_changes_for_edit?
    persisted? && (will_save_change_to_title? || will_save_change_to_url? || will_save_change_to_body?)
  end

  def stamp_edit_timestamp
    self.edited_at = Time.current
  end

  def reset_thumbnail_preview
    self.thumbnail_url = nil
    self.thumbnail_fetched_at = nil
  end

  def queue_thumbnail_refresh
    return if url.blank?

    FetchPostThumbnailJob.perform_later(id, url)
  end

  def respect_post_rate_limit
    return if user.blank?
    return unless user.posts.where("created_at >= ?", 1.hour.ago).count >= CommunitySetting.current.posts_per_hour

    errors.add(:base, "Voce atingiu o limite de posts por hora. Aguarde um pouco antes de publicar novamente.")
  end

  def prevent_duplicate_recent_posts
    return if user.blank?
    return unless user.posts.where("created_at >= ?", 12.hours.ago).where("LOWER(title) = ?", title.to_s.downcase).exists?

    errors.add(:title, "ja foi usado em um post recente seu. Ajuste o contexto antes de publicar de novo.")
  end
end
