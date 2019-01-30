  create_table "archive_trips", force: :cascade do |t|
    t.text     "origin"
    t.text     "destination"
    t.datetime "time"
    t.boolean  "arrive_by"
    t.string   "request_url"
    t.datetime "created_at",                                      null: false
    t.datetime "updated_at",                                      null: false
    t.integer  "api_key_id"
    t.integer  "service_id"
    t.integer  "api_call_id"
    t.integer  "orig_county_id"
    t.integer  "orig_nyct_zone_id"
    t.integer  "orig_lirr_area_id"
    t.integer  "orig_mnr_area_id"
    t.integer  "dest_county_id"
    t.integer  "dest_nyct_zone_id"
    t.integer  "dest_lirr_area_id"
    t.integer  "dest_mnr_area_id"
    t.integer  "platform_id"
    t.decimal  "origin_lat"
    t.decimal  "origin_lng"
    t.decimal  "destination_lat"
    t.decimal  "destination_lng"
    t.integer  "max_walk_seconds"
    t.integer  "min_walk_seconds"
    t.integer  "max_total_seconds"
    t.integer  "min_total_seconds"
    t.string   "otp_mode",               default: "WALK,TRANSIT", null: false
    t.decimal  "otp_walk_speed",                          default: "1.3",     null: false
    t.decimal  "otp_max_walk_distance",                   default: "8046.72", null: false
    t.decimal  "otp_walk_reluctance",                     default: "4.0",     null: false
    t.decimal  "otp_transfer_penalty",                    default: "600.0",   null: false
    t.boolean  "otp_accessible"
    t.integer  "otp_transfer_slack",                      default: 120,       null: false
    t.boolean  "otp_allow_unknown_transfers",             default: false,     null: false
    t.integer  "otp_use_unpreferred_routes_penalty",      default: 1200,      null: false
    t.integer  "otp_use_unpreferred_start_end_penalty",   default: 3600,      null: false
    t.integer  "otp_other_than_preferred_routes_penalty", default: 10800,     null: false
    t.decimal  "otp_car_reluctance",                      default: "4.0",     null: false
    t.string   "otp_path_comparator",                     default: "mta",     null: false
    t.integer  "otp_max_walk_distance_heuristic",         default: 8047,      null: false

  end

  create_table "archive_results", force: :cascade do |t|
    t.text     "otp_request"
    t.text     "otp_response"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
    t.integer  "trip_id"
    t.text     "otp_viewable_request"
    t.datetime "trip_time"
    t.index ["trip_id"], name: "index_results_on_trip_id", using: :btree
  end

  create_table "report_trips"
    t.integer  "api_key_id"
    t.integer  "service_id"
    t.integer  "api_call_id"
    t.datetime "date"
    t.integer  "num_calls"
  end

