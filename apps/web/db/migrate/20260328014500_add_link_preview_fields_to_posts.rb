class AddLinkPreviewFieldsToPosts < ActiveRecord::Migration[8.1]
  def change
    change_table :posts, bulk: true do |t|
      t.string :thumbnail_url
      t.datetime :thumbnail_fetched_at
    end
  end
end
