class ApiToken < ApplicationRecord
  TOKEN_PREFIX = "rvst"
  RAW_TOKEN_LENGTH = 48

  attr_reader :plain_text_token

  belongs_to :user

  before_validation :normalize_name

  validates :name, presence: true, length: { maximum: 80 }
  validates :token_digest, presence: true, uniqueness: true

  scope :recent_first, -> { order(created_at: :desc) }
  scope :active, -> { where(revoked_at: nil).where("expires_at IS NULL OR expires_at > ?", Time.current) }

  def self.issue!(user:, name:, expires_at: nil)
    raw_token = generate_raw_token
    create!(
      user:,
      name:,
      expires_at:,
      token_digest: digest(raw_token)
    ).tap do |token|
      token.instance_variable_set(:@plain_text_token, raw_token)
    end
  end

  def self.authenticate(raw_token)
    return if raw_token.blank?

    active.find_by(token_digest: digest(raw_token))
  end

  def self.digest(raw_token)
    Digest::SHA256.hexdigest(raw_token.to_s)
  end

  def self.generate_raw_token
    "#{TOKEN_PREFIX}_#{SecureRandom.urlsafe_base64(RAW_TOKEN_LENGTH)}"
  end

  def active?
    revoked_at.blank? && (expires_at.blank? || expires_at.future?)
  end

  def revoke!
    update!(revoked_at: Time.current)
  end

  def touch_last_used!
    update_column(:last_used_at, Time.current)
  end

  private

  def normalize_name
    self.name = name.to_s.squish
  end
end
