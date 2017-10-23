class CreateTrips < ActiveRecord::Migration[5.0]
  def change
    create_table :trips do |t|
      t.text :origin
      t.text :destination
      t.datetime :time
      t.boolean :arrive_by
      t.string :request_url
      t.timestamps
    end
  end
end
