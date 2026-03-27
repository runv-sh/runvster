class CreateCommentsVotesNotificationsAndModeration < ActiveRecord::Migration[8.1]
  def change
    create_table :comments do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :parent, foreign_key: { to_table: :comments }
      t.text :body, null: false
      t.integer :replies_count, default: 0, null: false

      t.timestamps
    end

    create_table :votes do |t|
      t.references :post, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :value, null: false

      t.timestamps
    end

    add_index :votes, [ :post_id, :user_id ], unique: true

    create_table :notifications do |t|
      t.references :recipient, null: false, foreign_key: { to_table: :users }
      t.references :actor, foreign_key: { to_table: :users }
      t.string :kind, null: false
      t.string :record_type, null: false
      t.bigint :record_id, null: false
      t.text :message, null: false
      t.datetime :read_at

      t.timestamps
    end

    add_index :notifications, [ :record_type, :record_id ]

    create_table :moderation_cases do |t|
      t.references :reporter, null: false, foreign_key: { to_table: :users }
      t.references :resolver, foreign_key: { to_table: :users }
      t.string :reportable_type, null: false
      t.bigint :reportable_id, null: false
      t.string :status, null: false, default: "open"
      t.string :reason, null: false
      t.text :details
      t.text :resolution_note
      t.datetime :resolved_at

      t.timestamps
    end

    add_index :moderation_cases, [ :reportable_type, :reportable_id ]

    create_table :admin_actions do |t|
      t.references :admin, null: false, foreign_key: { to_table: :users }
      t.string :action_type, null: false
      t.string :target_type, null: false
      t.bigint :target_id
      t.text :details

      t.timestamps
    end

    add_index :admin_actions, [ :target_type, :target_id ]
  end
end
