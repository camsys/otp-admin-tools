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

ActiveRecord::Schema.define(version: 20180116200043) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "configs", force: :cascade do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.text     "comment"
    t.string   "name"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.decimal  "otp_walk_speed"
    t.decimal  "otp_max_walk_distance"
    t.decimal  "otp_walk_reluctance"
    t.decimal  "otp_transfer_penalty"
    t.string   "atis_minimize"
    t.decimal  "atis_walk_dist"
    t.decimal  "atis_walk_speed"
    t.string   "atis_walk_increase"
    t.boolean  "otp_accessible"
    t.boolean  "atis_accessible"
  end

  create_table "results", force: :cascade do |t|
    t.text     "otp_request"
    t.text     "otp_response"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "trip_id"
    t.text     "otp_viewable_request"
    t.integer  "test_id"
    t.text     "atis_request"
    t.text     "atis_response"
    t.decimal  "percent_matched"
    t.index ["test_id"], name: "index_results_on_test_id", using: :btree
    t.index ["trip_id"], name: "index_results_on_trip_id", using: :btree
  end

  create_table "tests", force: :cascade do |t|
    t.text     "comment"
    t.datetime "created_at",            null: false
    t.datetime "updated_at",            null: false
    t.integer  "group_id"
    t.decimal  "otp_walk_speed"
    t.decimal  "otp_max_walk_distance"
    t.decimal  "otp_walk_reluctance"
    t.decimal  "otp_transfer_penalty"
    t.string   "atis_minimize"
    t.decimal  "atis_walk_dist"
    t.decimal  "atis_walk_speed"
    t.string   "atis_walk_increase"
    t.boolean  "otp_accessible"
    t.boolean  "atis_accessible"
    t.index ["group_id"], name: "index_tests_on_group_id", using: :btree
  end

  create_table "trips", force: :cascade do |t|
    t.text     "origin"
    t.text     "destination"
    t.datetime "time"
    t.boolean  "arrive_by"
    t.string   "request_url"
    t.datetime "created_at",      null: false
    t.datetime "updated_at",      null: false
    t.integer  "group_id"
    t.decimal  "origin_lat"
    t.decimal  "origin_lng"
    t.decimal  "destination_lat"
    t.decimal  "destination_lng"
    t.string   "atis_mode"
    t.index ["group_id"], name: "index_trips_on_group_id", using: :btree
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  default: "", null: false
    t.string   "encrypted_password",     default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet     "current_sign_in_ip"
    t.inet     "last_sign_in_ip"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
    t.string   "first_name"
    t.string   "last_name"
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
