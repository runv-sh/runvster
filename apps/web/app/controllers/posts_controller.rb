class PostsController < ApplicationController
  FEED_TABS = %w[recentes top links discussao].freeze
  PAGE_SIZE = 20
  RSS_PAGE_SIZE = 50
  PERIOD_FILTERS = {
    "24h" => 24.hours,
    "7d" => 7.days,
    "30d" => 30.days
  }.freeze

  before_action :require_authentication!, only: %i[new create edit update destroy]
  before_action :require_verified_email_for_posting!, only: :create
  before_action :set_post, only: %i[show edit update destroy]
  before_action :authorize_post_editor!, only: %i[edit update destroy]

  def index
    @feed_tab = params[:tab].presence_in(FEED_TABS) || "recentes"
    @current_query = params[:q].to_s.strip
    @current_tag = params[:tag].to_s.strip
    @current_author = params[:author].to_s.strip
    @current_period = params[:period].to_s.strip

    scope = apply_filters(posts_for(@feed_tab))

    if request.format.rss?
      @posts = scope.limit(RSS_PAGE_SIZE).to_a
      @feed_title = rss_feed_title
      @feed_description = rss_feed_description
      @feed_url = rss_feed_url(rss_request_params)
      return
    end

    @page = [params[:page].to_i, 1].max
    @total_posts = scope.count(:all)
    @posts = scope.offset((@page - 1) * PAGE_SIZE).limit(PAGE_SIZE).to_a
    @has_previous_page = @page > 1
    @has_next_page = (@page * PAGE_SIZE) < @total_posts
  end

  def show
    @comment = Comment.new
    @root_comments = @post.all_comments.visible.root_level.includes(:user, replies: :user).chronological
    @featured_tags = Tag.featured.limit(8)
  end

  def new
    @post = current_user.posts.build
  end

  def edit
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

  def update
    @post.assign_attributes(post_params)
    @post.assign_tag_names(params.dig(:post, :tag_names))

    if @post.save
      redirect_to @post, notice: "Post atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    owner = @post.user
    @post.destroy!
    redirect_to user_path(owner), notice: "Post excluido."
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
    return unless @post.hidden? && !current_user&.staff?

    redirect_to root_path, alert: "Esse post foi ocultado pela moderacao."
  end

  def authorize_post_editor!
    return if @post.editable_by?(current_user)

    redirect_to @post, alert: "Voce nao pode editar esse post."
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

  def rss_request_params
    request.query_parameters.except("page").merge(tab: rss_tab_param).compact_blank
  end

  def rss_tab_param
    @feed_tab == "recentes" ? nil : @feed_tab
  end

  def rss_feed_title
    base = case @feed_tab
           when "top"
             "Runvster Top"
           when "links"
             "Runvster Links"
           when "discussao"
             "Runvster Discussao"
           else
             "Runvster Feed"
           end

    qualifiers = []
    qualifiers << "##{@current_tag}" if @current_tag.present?
    qualifiers << "@#{@current_author}" if @current_author.present?
    qualifiers << "busca: #{@current_query}" if @current_query.present?
    qualifiers << @current_period if @current_period.present?

    ([base] + qualifiers).join(" · ")
  end

  def rss_feed_description
    description = "Feed RSS do Runvster com links e discussoes em alta densidade."
    return description if [@current_query, @current_tag, @current_author, @current_period].all?(&:blank?)

    [description, "Filtros ativos: #{rss_request_params.except(:tab).values.join(', ')}."].join(" ")
  end
end
