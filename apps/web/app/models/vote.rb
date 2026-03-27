class Vote < ApplicationRecord
  belongs_to :post, counter_cache: true
  belongs_to :user

  validates :value, inclusion: { in: [ -1, 1 ] }
  validates :user_id, uniqueness: { scope: :post_id }

  after_commit :refresh_post_score!

  private

  def refresh_post_score!
    post.update_columns(score: post.votes.sum(:value))
  end
end
