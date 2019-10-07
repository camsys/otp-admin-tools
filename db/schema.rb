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

ActiveRecord::Schema.define(version: 20190401153033) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "api_calls", force: :cascade do |t|
    t.integer  "type_id"
    t.integer  "api_key_id"
    t.datetime "server_time"
    t.string   "platform"
    t.string   "session"
  end

  create_table "api_keys", force: :cascade do |t|
    t.string "api_key"
    t.string "consumer_name"
  end

  create_table "configs", force: :cascade do |t|
    t.string   "key"
    t.text     "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", force: :cascade do |t|
    t.text     "comment"
    t.string   "name"
    t.datetime "created_at",                                                  null: false
    t.datetime "updated_at",                                                  null: false
    t.decimal  "otp_walk_speed",                          default: "1.3",     null: false
    t.decimal  "otp_max_walk_distance",                   default: "8046.72", null: false
    t.decimal  "otp_walk_reluctance",                     default: "4.0",     null: false
    t.decimal  "otp_transfer_penalty",                    default: "600.0",   null: false
    t.string   "atis_minimize"
    t.decimal  "atis_walk_dist"
    t.decimal  "atis_walk_speed"
    t.string   "atis_walk_increase"
    t.boolean  "otp_accessible"
    t.boolean  "atis_accessible"
    t.string   "compare_type"
    t.integer  "otp_transfer_slack",                      default: 120,       null: false
    t.boolean  "otp_allow_unknown_transfers",             default: false,     null: false
    t.integer  "otp_use_unpreferred_routes_penalty",      default: 1200,      null: false
    t.integer  "otp_use_unpreferred_start_end_penalty",   default: 3600,      null: false
    t.integer  "otp_other_than_preferred_routes_penalty", default: 10800,     null: false
    t.decimal  "otp_car_reluctance",                      default: "4.0",     null: false
    t.string   "otp_path_comparator",                     default: "mta",     null: false
    t.integer  "otp_max_walk_distance_heuristic",         default: 8047,      null: false
  end

  create_table "locations", force: :cascade do |t|
    t.integer "category"
    t.string  "name"
    t.text    "geojson"
  end

  create_table "plan_locations", force: :cascade do |t|
    t.integer  "plan_id"
    t.integer  "category_id"
    t.integer  "from_category_id"
    t.integer  "to_category_id"
    t.datetime "plan_request_time"
    t.index ["plan_id"], name: "index_plan_locations_on_plan_id", using: :btree
  end

  create_table "plans", force: :cascade do |t|
    t.integer  "type_id"
    t.decimal  "from_lat"
    t.decimal  "from_lng"
    t.decimal  "to_lat"
    t.decimal  "to_lng"
    t.datetime "request_time"
    t.datetime "server_time"
    t.boolean  "arrive_by"
  end

  create_table "results", force: :cascade do |t|
    t.text     "otp_request"
    t.text     "otp_response"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "trip_id"
    t.text     "otp_viewable_request"
    t.integer  "test_id"
    t.text     "compare_request"
    t.text     "compare_response"
    t.decimal  "percent_matched"
    t.datetime "trip_time"
    t.index ["test_id"], name: "index_results_on_test_id", using: :btree
    t.index ["trip_id"], name: "index_results_on_trip_id", using: :btree
  end

  create_table "tests", force: :cascade do |t|
    t.text     "comment"
    t.datetime "created_at",                                              null: false
    t.datetime "updated_at",                                              null: false
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
    t.integer  "otp_transfer_slack",                      default: 120,   null: false
    t.boolean  "otp_allow_unknown_transfers",             default: false, null: false
    t.integer  "otp_use_unpreferred_routes_penalty",      default: 1200,  null: false
    t.integer  "otp_use_unpreferred_start_end_penalty",   default: 3600,  null: false
    t.integer  "otp_other_than_preferred_routes_penalty", default: 10800, null: false
    t.decimal  "otp_car_reluctance",                      default: "4.0", null: false
    t.string   "otp_path_comparator",                     default: "mta", null: false
    t.integer  "otp_max_walk_distance_heuristic",         default: 8047,  null: false
    t.index ["group_id"], name: "index_tests_on_group_id", using: :btree
  end

  create_table "trips", force: :cascade do |t|
    t.text     "origin"
    t.text     "destination"
    t.datetime "time"
    t.boolean  "arrive_by"
    t.string   "request_url"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "group_id"
    t.decimal  "origin_lat"
    t.decimal  "origin_lng"
    t.decimal  "destination_lat"
    t.decimal  "destination_lng"
    t.string   "atis_mode"
    t.boolean  "atis_accessible"
    t.string   "expected_route_pattern"
    t.integer  "max_walk_seconds"
    t.integer  "min_walk_seconds"
    t.integer  "max_total_seconds"
    t.integer  "min_total_seconds"
    t.string   "otp_mode",               default: "WALK,TRANSIT", null: false
    t.index ["group_id"], name: "index_trips_on_group_id", using: :btree
  end

  create_table "types", force: :cascade do |t|
    t.string "name"
    t.string "description"
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
