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

ActiveRecord::Schema[7.1].define(version: 2023_10_05_112509) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "dway_users", force: :cascade do |t|
    t.string "uid", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["uid"], name: "index_dway_users_on_uid", unique: true
  end

  create_table "requests", force: :cascade do |t|
    t.bigint "dway_user_id", null: false
    t.bigint "submission_id"
    t.integer "status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dway_user_id"], name: "index_requests_on_dway_user_id"
    t.index ["submission_id"], name: "index_requests_on_submission_id"
  end

  create_table "submissions", force: :cascade do |t|
    t.bigint "dway_user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["dway_user_id"], name: "index_submissions_on_dway_user_id"
  end

  add_foreign_key "requests", "dway_users"
  add_foreign_key "requests", "submissions"
  add_foreign_key "submissions", "dway_users"
end
