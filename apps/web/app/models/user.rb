class User < ApplicationRecord
  has_secure_password

  has_many :posts, dependent: :destroy

  enum :role, { member: "member", moderator: "moderator", admin: "admin" }, default: :member, validate: true

  before_validation :normalize_identity_fields

  validates :email, presence: true, uniqueness: true
  validates :username,
    presence: true,
    uniqueness: true,
    length: { in: 3..24 },
    format: { with: /\A[a-z0-9_]+\z/, message: "use apenas letras minúsculas, números e _" }
  validates :password, length: { minimum: 8 }, if: -> { password.present? }
  validates :bio, length: { maximum: 280 }

  def to_param
    username
  end

  private

  def normalize_identity_fields
    self.email = email.to_s.strip.downcase
    self.username = username.to_s.strip.downcase
    self.bio = bio.to_s.squish.presence
  end
end
