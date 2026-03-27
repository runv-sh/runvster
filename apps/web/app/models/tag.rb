class Tag < ApplicationRecord
  has_many :taggings, dependent: :destroy
  has_many :posts, through: :taggings

  before_validation :normalize_fields

  validates :name, presence: true, uniqueness: true, length: { in: 2..24 }
  validates :slug, presence: true, uniqueness: true, length: { in: 2..24 }
  validates :description, length: { maximum: 160 }

  scope :featured, -> { order(posts_count: :desc, name: :asc) }
  scope :alphabetical, -> { order(name: :asc) }

  def to_param
    slug
  end

  private

  def normalize_fields
    normalized = name.to_s.strip.downcase.gsub(/[^a-z0-9\- ]/, "").tr(" ", "-").gsub(/-{2,}/, "-").gsub(/\A-|-+\z/, "")
    self.name = normalized
    self.slug = normalized if slug.blank?
    self.description = description.to_s.squish.presence
  end
end
