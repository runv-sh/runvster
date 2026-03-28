module Api
  module V1
    class TagsController < BaseController
      include Concerns::Serialization

      def index
        tags = params[:featured].present? ? Tag.featured.limit(20) : Tag.alphabetical
        render json: { tags: tags.map { |tag| serialize_tag(tag) } }
      end

      def show
        tag = Tag.find_by!(slug: params[:id].to_s.downcase)
        posts = tag.posts.visible.includes(:user, :tags).order(score: :desc, created_at: :desc)

        render json: {
          tag: serialize_tag(tag),
          posts: posts.map { |post| serialize_post(post, current_user:) }
        }
      end
    end
  end
end
