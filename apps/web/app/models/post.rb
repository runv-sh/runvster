class Post < ApplicationRecord
  MAX_TAGS = 3

  belongs_to :user, counter_cache: true

  has_many :comments, -> { includes(:user, replies: :user).chronological }, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :taggings, dependent: :destroy
  has_many :tags, -> { order(name: :asc) }, through: :taggings
  has_many :moderation_cases, as: :reportable, dependent: :destroy

  before_validation :normalize_fields

  validates :title, presence: true, length: { in: 8..140 }
  validates :url, format: { with: URI::DEFAULT_PARSER.make_regexp(%w[http https]) }, allow_blank: true
  validates :body, length: { maximum: 5000 }

  validate :url_or_body_present
  validate :tag_count_within_limits

  scope :with_feed_associations, -> { includes(:user, :tags) }
  scope :recent_first, -> { with_feed_associations.order(created_at: :desc) }
  scope :link_posts, -> { where.not(url: [nil, ""]) }
  scope :discussion_posts, -> { where(url: [nil, ""]).where.not(body: [nil, ""]) }
  scope :links_first, -> { link_posts.recent_first }
  scope :discussion_first, -> { discussion_posts.recent_first }
  scope :top_first, lambda {
    with_feed_associations
      .order(
        Arel.sql(
          "((posts.score * 8) + (posts.comments_count * 3) + GREATEST(0, 72 - (EXTRACT(EPOCH FROM (NOW() - posts.created_at)) / 3600.0))) DESC, posts.created_at DESC"
        )
      )
  }

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

  def display_host
    URI.parse(url).host&.sub(/\Awww\./, "") if url.present?
  rescue URI::InvalidURIError
    nil
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
end
