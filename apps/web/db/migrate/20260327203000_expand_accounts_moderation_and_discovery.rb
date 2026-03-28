class ExpandAccountsModerationAndDiscovery < ActiveRecord::Migration[8.1]
  def change
    create_table :community_settings do |t|
      t.integer :member_invite_limit, null: false, default: 5
      t.integer :member_invite_unlock_days, null: false, default: 30
      t.integer :invite_expiration_days, null: false, default: 14
      t.integer :posts_per_hour, null: false, default: 3
      t.integer :comments_per_ten_minutes, null: false, default: 12
      t.integer :reports_per_hour, null: false, default: 6
      t.boolean :require_email_verification_for_posting, null: false, default: false
      t.boolean :require_email_verification_for_invites, null: false, default: false

      t.timestamps
    end

    change_table :users, bulk: true do |t|
      t.string :account_state, null: false, default: "active"
      t.datetime :suspended_until
      t.text :moderation_note
      t.datetime :email_verified_at
      t.string :email_confirmation_token
      t.datetime :email_confirmation_sent_at
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.boolean :notify_on_comments, null: false, default: true
      t.boolean :notify_on_replies, null: false, default: true
      t.boolean :notify_on_invites, null: false, default: true
      t.boolean :notify_on_moderation, null: false, default: true
      t.string :digest_frequency, null: false, default: "off"
      t.datetime :last_digest_sent_at
    end

    add_index :users, :account_state
    add_index :users, :email_confirmation_token, unique: true
    add_index :users, :password_reset_token, unique: true

    add_reference :posts, :hidden_by, foreign_key: { to_table: :users }
    add_column :posts, :hidden_at, :datetime
    add_column :posts, :hidden_reason, :string
    add_column :posts, :edited_at, :datetime
    add_index :posts, :hidden_at

    add_reference :comments, :hidden_by, foreign_key: { to_table: :users }
    add_column :comments, :hidden_at, :datetime
    add_column :comments, :hidden_reason, :string
    add_column :comments, :edited_at, :datetime
    add_index :comments, :hidden_at

    change_table :invitations, bulk: true do |t|
      t.integer :sent_count, null: false, default: 0
      t.datetime :last_sent_at
      t.datetime :reminder_sent_at
      t.string :batch_label
    end

    add_index :invitations, :last_sent_at
  end
end
