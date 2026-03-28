class FetchPostThumbnailJob < ApplicationJob
  queue_as :default

  def perform(post_id, expected_url = nil)
    post = Post.find_by(id: post_id)
    return if post.blank? || post.url.blank?
    return if expected_url.present? && post.url != expected_url

    preview = LinkPreviewFetcher.call(post.url)

    post.update_columns(
      thumbnail_url: preview&.fetch(:thumbnail_url),
      thumbnail_fetched_at: Time.current
    )
  end
end
