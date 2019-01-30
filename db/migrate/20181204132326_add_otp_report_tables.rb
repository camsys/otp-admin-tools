class AddOtpReportTables < ActiveRecord::Migration[5.0]
  def change

	  create_table :types do |t|
	    t.string  "name"
	    t.string  "description"
	  end

	  create_table :api_keys do |t|
	    t.string  "api_key"
	    t.string  "consumer_name"
	  end

	  create_table :plans do |t|
	    t.integer  "type_id"
	    t.decimal  "from_lat"
	    t.decimal  "from_lng"
	    t.decimal  "to_lat"
	    t.decimal  "to_lng"
	    t.datetime "request_time"
	    t.datetime "server_time"
    	t.boolean  "arrive_by"
	  end

	  create_table :api_calls do |t|
	    t.integer  "type_id"
	    t.integer  "api_key_id"
	    t.datetime "server_time"
	    t.string  "platform"
	    t.string  "session"
	  end

	  create_table :locations do |t|
	    t.integer  "category"
	    t.string  "name"
	    t.string  "geojson"
	  end

	  create_table "plan_locations" do |t|
	  	t.belongs_to :plan, index: true
	    t.integer  "category_id"
	    t.integer  "from_category_id"
	    t.integer  "to_category_id"
	  end

  end
end
