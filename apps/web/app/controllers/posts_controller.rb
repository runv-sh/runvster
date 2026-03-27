class PostsController < ApplicationController
  FEED_TABS = %w[recentes top links discussao].freeze

  before_action :require_authentication!, only: %i[new create]
  before_action :set_post, only: :show

  def index
    @feed_tab = params[:tab].presence_in(FEED_TABS) || "recentes"
    @posts = posts_for(@feed_tab).to_a
  end

  def show
    @featured_tags = Tag.featured.limit(8)
  end

  def new
    @post = current_user.posts.build
  end

  def create
    @post = current_user.posts.build(post_params)
    @post.assign_tag_names(params.dig(:post, :tag_names))

    if @post.save
      redirect_to @post, notice: "Post publicado."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def post_params
    params.expect(post: %i[title url body])
  end

  def posts_for(tab)
    case tab
    when "top"
      Post.top_first
    when "links"
      Post.links_first
    when "discussao"
      Post.discussion_first
    else
      Post.recent_first
    end
  end

  def set_post
    @post = Post.includes(:user, :tags).find(params[:id])
  end
end
