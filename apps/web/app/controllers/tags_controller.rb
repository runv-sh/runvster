class TagsController < ApplicationController
  def show
    @tag = Tag.find_by!(slug: params[:id].to_s.downcase)
    @posts = @tag.posts.visible.includes(:user, :tags).order(score: :desc, created_at: :desc)
    @related_tags = Tag.featured.where.not(id: @tag.id).limit(8)
  end
end
