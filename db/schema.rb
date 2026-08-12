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

ActiveRecord::Schema[8.1].define(version: 2026_08_12_043400) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "bookings", force: :cascade do |t|
    t.datetime "confirmation_sent_at"
    t.datetime "created_at", null: false
    t.string "email"
    t.datetime "email_failed_at"
    t.string "failure_reason"
    t.string "learner_name"
    t.string "status", default: "confirmed"
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index ["workspace_id"], name: "index_bookings_on_workspace_id"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "booking_id"
    t.datetime "created_at", null: false
    t.string "message_id"
    t.string "recipient"
    t.string "status", default: "accepted"
    t.string "status_reason"
    t.string "subject"
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index ["booking_id"], name: "index_messages_on_booking_id"
    t.index ["message_id"], name: "index_messages_on_message_id", unique: true
    t.index ["workspace_id"], name: "index_messages_on_workspace_id"
  end

  create_table "suppressions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "event_type"
    t.string "reason"
    t.datetime "updated_at", null: false
    t.bigint "workspace_id", null: false
    t.index ["workspace_id", "email"], name: "index_suppressions_on_workspace_id_and_email", unique: true
    t.index ["workspace_id"], name: "index_suppressions_on_workspace_id"
  end

  create_table "workspaces", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "last_seen_at"
    t.string "token"
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_workspaces_on_token", unique: true
  end

  add_foreign_key "bookings", "workspaces"
  add_foreign_key "messages", "bookings"
  add_foreign_key "messages", "workspaces"
  add_foreign_key "suppressions", "workspaces"
end
