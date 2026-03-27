# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_03_27_152000) do
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_actions", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.string "action_type", null: false
    t.string "target_type", null: false
    t.bigint "target_id"
    t.text "details"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_actions_on_admin_id"
    t.index ["target_type", "target_id"], name: "index_admin_actions_on_target_type_and_target_id"
  end

  create_table "comments", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.bigint "parent_id"
    t.text "body", null: false
    t.integer "replies_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "invitations", force: :cascade do |t|
    t.bigint "inviter_id", null: false
    t.bigint "invitee_id"
    t.string "recipient_email", null: false
    t.string "token", null: false
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.text "acceptance_note"
    t.index ["invitee_id"], name: "index_invitations_on_invitee_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["recipient_email"], name: "index_invitations_on_recipient_email"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "moderation_cases", force: :cascade do |t|
    t.bigint "reporter_id", null: false
    t.bigint "resolver_id"
    t.string "reportable_type", null: false
    t.bigint "reportable_id", null: false
    t.string "status", default: "open", null: false
    t.string "reason", null: false
    t.text "details"
    t.text "resolution_note"
    t.datetime "resolved_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_moderation_cases_on_reportable_type_and_reportable_id"
    t.index ["reporter_id"], name: "index_moderation_cases_on_reporter_id"
    t.index ["resolver_id"], name: "index_moderation_cases_on_resolver_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "recipient_id", null: false
    t.bigint "actor_id"
    t.string "kind", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.text "message", null: false
    t.datetime "read_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["record_type", "record_id"], name: "index_notifications_on_record_type_and_record_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.datetime "created_at", null: false
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id", null: false
    t.integer "comments_count", default: 0, null: false
    t.integer "votes_count", default: 0, null: false
    t.integer "score", default: 0, null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "taggings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "tag_id"], name: "index_taggings_on_post_id_and_tag_id", unique: true
    t.index ["post_id"], name: "index_taggings_on_post_id"
    t.index ["tag_id"], name: "index_taggings_on_tag_id"
  end

  create_table "tags", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.integer "posts_count", default: 0, null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_tags_on_name", unique: true
    t.index ["slug"], name: "index_tags_on_slug", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "posts_count", default: 0, null: false
    t.string "role", default: "member", null: false
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.bigint "post_id", null: false
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["post_id", "user_id"], name: "index_votes_on_post_id_and_user_id", unique: true
    t.index ["post_id"], name: "index_votes_on_post_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "admin_actions", "users", column: "admin_id"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "invitations", "users", column: "invitee_id"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "moderation_cases", "users", column: "reporter_id"
  add_foreign_key "moderation_cases", "users", column: "resolver_id"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "posts", "users"
  add_foreign_key "taggings", "posts"
  add_foreign_key "taggings", "tags"
  add_foreign_key "votes", "posts"
  add_foreign_key "votes", "users"
end
