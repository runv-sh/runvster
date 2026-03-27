class AddEngagementAndInvitePolicyFields < ActiveRecord::Migration[8.1]
  def change
    change_table :posts, bulk: true do |t|
      t.integer :comments_count, default: 0, null: false
      t.integer :votes_count, default: 0, null: false
      t.integer :score, default: 0, null: false
    end

    change_table :invitations, bulk: true do |t|
      t.datetime :expires_at
      t.datetime :revoked_at
      t.text :acceptance_note
    end
  end
end
