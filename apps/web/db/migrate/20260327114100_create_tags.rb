class CreateTags < ActiveRecord::Migration[8.1]
  def change
    create_table :tags do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.integer :posts_count, null: false, default: 0

      t.timestamps
    end

    add_index :tags, :name, unique: true
    add_index :tags, :slug, unique: true
  end
end
