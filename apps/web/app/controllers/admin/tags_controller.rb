module Admin
  class TagsController < ApplicationController
    before_action :require_admin!

    def index
      @tags = Tag.alphabetical
    end

    def update
      tag = Tag.find(params[:id])

      if tag.update(params.expect(tag: [ :name, :slug, :description ]))
        AdminAction.create!(
          admin: current_user,
          action_type: "tag_updated",
          target_type: "Tag",
          target_id: tag.id,
          details: "Descricao da tag #{tag.slug} atualizada."
        )
        redirect_to admin_tags_path, notice: "Tag atualizada."
      else
        redirect_to admin_tags_path, alert: tag.errors.full_messages.to_sentence
      end
    end

    def destroy
      tag = Tag.find(params[:id])

      if tag.posts.exists?
        return redirect_to admin_tags_path, alert: "Nao e possivel excluir uma tag que ainda possui posts associados."
      end

      slug = tag.slug
      tag.destroy!

      AdminAction.create!(
        admin: current_user,
        action_type: "tag_deleted",
        target_type: "Tag",
        target_id: tag.id,
        details: "Tag ##{slug} excluida."
      )
      redirect_to admin_tags_path, notice: "Tag excluida."
    end
  end
end
