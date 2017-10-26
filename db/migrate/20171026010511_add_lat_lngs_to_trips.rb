class AddLatLngsToTrips < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :origin_lat, :decimal
    add_column :trips, :origin_lng, :decimal
    add_column :trips, :destination_lat, :decimal
    add_column :trips, :destination_lng, :decimal
  end
end
