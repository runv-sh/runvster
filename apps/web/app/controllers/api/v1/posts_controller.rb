module Api
  module V1
    class PostsController < BaseController
      include Concerns::Serialization

      PAGE_SIZE = 20
      FEED_TABS = ::PostsController::FEED_TABS
      PERIOD_FILTERS = ::PostsController::PERIOD_FILTERS

      before_action :require_authentication!, only: %i[create update destroy]
      before_action :require_verified_email_for_posting!, only: :create
      before_action :set_post, only: %i[show update destroy]
      before_action :authorize_post_editor!, only: %i[update destroy]

      def index
        feed_tab = params[:tab].presence_in(FEED_TABS) || "recentes"
        scope = apply_filters(posts_for(feed_tab))
        page = [params[:page].to_i, 1].max
        paged_scope = scope.offset((page - 1) * PAGE_SIZE).limit(PAGE_SIZE)

        render json: {
          posts: paged_scope.map { |post| serialize_post(post, current_user:) },
          meta: pagination_meta(scope, page:, page_size: PAGE_SIZE),
          filters: {
            tab: feed_tab,
            query: params[:q].to_s.strip,
            tag: params[:tag].to_s.strip,
            author: params[:author].to_s.strip,
            period: params[:period].to_s.strip
          }
        }
      end

      def show
        render json: { post: serialize_post(@post, current_user:, include_comments: true) }
      end

      def create
        post = current_user.posts.build(post_params)
        post.assign_tag_names(params.dig(:post, :tag_names))

        if post.save
          render json: { post: serialize_post(post, current_user:) }, status: :created
        else
          render_validation_errors(post)
        end
      end

      def update
        @post.assign_attributes(post_params)
        @post.assign_tag_names(params.dig(:post, :tag_names))

        if @post.save
          render json: { post: serialize_post(@post, current_user:, include_comments: true) }
        else
          render_validation_errors(@post)
        end
      end

      def destroy
        @post.destroy!
        head :no_content
      end

      private

      def post_params
        params.expect(post: %i[title url body])
      end

      def posts_for(tab)
        case tab
        when "top" then Post.top_first
        when "links" then Post.links_first
        when "discussao" then Post.discussion_first
        else Post.recent_first
        end
      end

      def apply_filters(scope)
        filtered_scope = scope
        filtered_scope = filtered_scope.matching_query(params[:q]) if params[:q].present?
        filtered_scope = filtered_scope.tagged_with(params[:tag]) if params[:tag].present?
        filtered_scope = filtered_scope.authored_by(params[:author]) if params[:author].present?

        if params[:period].present? && PERIOD_FILTERS.key?(params[:period])
          filtered_scope = filtered_scope.where("posts.created_at >= ?", PERIOD_FILTERS.fetch(params[:period]).ago)
        end

        filtered_scope
      end

      def set_post
        @post = Post.includes(:user, :tags).find(params[:id])
        return unless @post.hidden? && !current_user&.staff?

        render_error("post_hidden", "Esse post foi ocultado pela moderacao.", :forbidden)
      end

      def authorize_post_editor!
        return if @post.editable_by?(current_user)

        render_error("forbidden", "Voce nao pode editar esse post.", :forbidden)
      end
    end
  end
end
