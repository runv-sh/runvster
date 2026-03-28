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

ActiveRecord::Schema[8.1].define(version: 2026_03_28_023000) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admin_actions", force: :cascade do |t|
    t.string "action_type", null: false
    t.bigint "admin_id", null: false
    t.datetime "created_at", null: false
    t.text "details"
    t.bigint "target_id"
    t.string "target_type", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_admin_actions_on_admin_id"
    t.index ["target_type", "target_id"], name: "index_admin_actions_on_target_type_and_target_id"
  end

  create_table "api_tokens", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "token_digest", null: false
    t.datetime "last_used_at"
    t.datetime "expires_at"
    t.datetime "revoked_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["revoked_at"], name: "index_api_tokens_on_revoked_at"
    t.index ["token_digest"], name: "index_api_tokens_on_token_digest", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "comments", force: :cascade do |t|
    t.text "body", null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.datetime "hidden_at"
    t.bigint "hidden_by_id"
    t.string "hidden_reason"
    t.bigint "parent_id"
    t.bigint "post_id", null: false
    t.integer "replies_count", default: 0, null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["hidden_at"], name: "index_comments_on_hidden_at"
    t.index ["hidden_by_id"], name: "index_comments_on_hidden_by_id"
    t.index ["parent_id"], name: "index_comments_on_parent_id"
    t.index ["post_id"], name: "index_comments_on_post_id"
    t.index ["user_id"], name: "index_comments_on_user_id"
  end

  create_table "community_settings", force: :cascade do |t|
    t.integer "comments_per_ten_minutes", default: 12, null: false
    t.datetime "created_at", null: false
    t.integer "invite_expiration_days", default: 14, null: false
    t.integer "member_invite_limit", default: 5, null: false
    t.integer "member_invite_unlock_days", default: 30, null: false
    t.integer "posts_per_hour", default: 3, null: false
    t.integer "reports_per_hour", default: 6, null: false
    t.boolean "require_email_verification_for_invites", default: false, null: false
    t.boolean "require_email_verification_for_posting", default: false, null: false
    t.datetime "updated_at", null: false
  end

  create_table "invitations", force: :cascade do |t|
    t.text "acceptance_note"
    t.datetime "accepted_at"
    t.string "batch_label"
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.bigint "invitee_id"
    t.bigint "inviter_id", null: false
    t.datetime "last_sent_at"
    t.string "recipient_email", null: false
    t.datetime "reminder_sent_at"
    t.datetime "revoked_at"
    t.integer "sent_count", default: 0, null: false
    t.string "token", null: false
    t.datetime "updated_at", null: false
    t.index ["invitee_id"], name: "index_invitations_on_invitee_id"
    t.index ["inviter_id"], name: "index_invitations_on_inviter_id"
    t.index ["last_sent_at"], name: "index_invitations_on_last_sent_at"
    t.index ["recipient_email"], name: "index_invitations_on_recipient_email"
    t.index ["token"], name: "index_invitations_on_token", unique: true
  end

  create_table "moderation_cases", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "details"
    t.string "reason", null: false
    t.bigint "reportable_id", null: false
    t.string "reportable_type", null: false
    t.bigint "reporter_id", null: false
    t.text "resolution_note"
    t.datetime "resolved_at"
    t.bigint "resolver_id"
    t.string "status", default: "open", null: false
    t.datetime "updated_at", null: false
    t.index ["reportable_type", "reportable_id"], name: "index_moderation_cases_on_reportable_type_and_reportable_id"
    t.index ["reporter_id"], name: "index_moderation_cases_on_reporter_id"
    t.index ["resolver_id"], name: "index_moderation_cases_on_resolver_id"
  end

  create_table "notifications", force: :cascade do |t|
    t.bigint "actor_id"
    t.datetime "created_at", null: false
    t.string "kind", null: false
    t.text "message", null: false
    t.datetime "read_at"
    t.bigint "recipient_id", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_notifications_on_actor_id"
    t.index ["recipient_id"], name: "index_notifications_on_recipient_id"
    t.index ["record_type", "record_id"], name: "index_notifications_on_record_type_and_record_id"
  end

  create_table "posts", force: :cascade do |t|
    t.text "body"
    t.integer "comments_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "edited_at"
    t.datetime "hidden_at"
    t.bigint "hidden_by_id"
    t.string "hidden_reason"
    t.integer "score", default: 0, null: false
    t.datetime "thumbnail_fetched_at"
    t.string "thumbnail_url"
    t.string "title", null: false
    t.datetime "updated_at", null: false
    t.string "url"
    t.bigint "user_id", null: false
    t.integer "votes_count", default: 0, null: false
    t.index ["created_at"], name: "index_posts_on_created_at"
    t.index ["hidden_at"], name: "index_posts_on_hidden_at"
    t.index ["hidden_by_id"], name: "index_posts_on_hidden_by_id"
    t.index ["user_id"], name: "index_posts_on_user_id"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.string "concurrency_key", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "error"
    t.bigint "job_id", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "active_job_id"
    t.text "arguments"
    t.string "class_name", null: false
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "finished_at"
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at"
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "queue_name", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "hostname"
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.text "metadata"
    t.string "name", null: false
    t.integer "pid", null: false
    t.bigint "supervisor_id"
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.datetime "run_at", null: false
    t.string "task_key", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.text "arguments"
    t.string "class_name"
    t.string "command", limit: 2048
    t.datetime "created_at", null: false
    t.text "description"
    t.string "key", null: false
    t.integer "priority", default: 0
    t.string "queue_name"
    t.string "schedule", null: false
    t.boolean "static", default: true, null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "job_id", null: false
    t.integer "priority", default: 0, null: false
    t.string "queue_name", null: false
    t.datetime "scheduled_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "expires_at", null: false
    t.string "key", null: false
    t.datetime "updated_at", null: false
    t.integer "value", default: 1, null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
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
    t.string "account_state", default: "active", null: false
    t.text "bio"
    t.datetime "created_at", null: false
    t.string "digest_frequency", default: "off", null: false
    t.string "email", null: false
    t.datetime "email_confirmation_sent_at"
    t.string "email_confirmation_token"
    t.datetime "email_verified_at"
    t.datetime "last_digest_sent_at"
    t.text "moderation_note"
    t.boolean "notify_on_comments", default: true, null: false
    t.boolean "notify_on_invites", default: true, null: false
    t.boolean "notify_on_moderation", default: true, null: false
    t.boolean "notify_on_replies", default: true, null: false
    t.string "password_digest", null: false
    t.datetime "password_reset_sent_at"
    t.string "password_reset_token"
    t.integer "posts_count", default: 0, null: false
    t.string "role", default: "member", null: false
    t.datetime "suspended_until"
    t.datetime "updated_at", null: false
    t.string "username", null: false
    t.index ["account_state"], name: "index_users_on_account_state"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["email_confirmation_token"], name: "index_users_on_email_confirmation_token", unique: true
    t.index ["password_reset_token"], name: "index_users_on_password_reset_token", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "votes", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "post_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.integer "value", null: false
    t.index ["post_id", "user_id"], name: "index_votes_on_post_id_and_user_id", unique: true
    t.index ["post_id"], name: "index_votes_on_post_id"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

  add_foreign_key "admin_actions", "users", column: "admin_id"
  add_foreign_key "api_tokens", "users"
  add_foreign_key "comments", "comments", column: "parent_id"
  add_foreign_key "comments", "posts"
  add_foreign_key "comments", "users"
  add_foreign_key "comments", "users", column: "hidden_by_id"
  add_foreign_key "invitations", "users", column: "invitee_id"
  add_foreign_key "invitations", "users", column: "inviter_id"
  add_foreign_key "moderation_cases", "users", column: "reporter_id"
  add_foreign_key "moderation_cases", "users", column: "resolver_id"
  add_foreign_key "notifications", "users", column: "actor_id"
  add_foreign_key "notifications", "users", column: "recipient_id"
  add_foreign_key "posts", "users"
  add_foreign_key "posts", "users", column: "hidden_by_id"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "taggings", "posts"
  add_foreign_key "taggings", "tags"
  add_foreign_key "votes", "posts"
  add_foreign_key "votes", "users"
end

