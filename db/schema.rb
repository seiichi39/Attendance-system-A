# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20220620112403) do

  create_table "attendances", force: :cascade do |t|
    t.date "worked_on"
    t.datetime "started_at"
    t.datetime "finished_at"
    t.string "note"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "scheduled_finished_at"
    t.float "over_work_time"
    t.boolean "overwork_next_day", default: false
    t.boolean "modification_next_day", default: false
    t.string "business_processing_content"
    t.integer "request_user"
    t.string "overwork_request_status"
    t.string "modification_request_status"
    t.string "one_month_request_status"
    t.integer "overwork_request_destination"
    t.integer "modification_request_destination"
    t.integer "one_month_request_destination"
    t.boolean "modification_change", default: false
    t.boolean "overwork_change", default: false
    t.boolean "one_month_change", default: false
    t.datetime "before_change_started_at"
    t.datetime "before_change_finished_at"
    t.datetime "after_change_started_at"
    t.datetime "after_change_finished_at"
    t.datetime "initial_started_at"
    t.datetime "initial_finished_at"
    t.datetime "change_attendance_approval_date"
    t.index ["user_id"], name: "index_attendances_on_user_id"
  end

  create_table "bases", force: :cascade do |t|
    t.string "base_number"
    t.string "base_name"
    t.string "base_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "password_digest"
    t.string "remember_digest"
    t.boolean "admin", default: false
    t.string "department"
    t.datetime "basic_time", default: "2022-07-22 23:00:00"
    t.datetime "work_time", default: "2022-07-22 22:30:00"
    t.integer "employee_number"
    t.string "uid"
    t.boolean "superior", default: false
    t.datetime "basic_work_time"
    t.datetime "designed_work_start_time"
    t.datetime "designed_work_end_time"
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
