class AddMaxWalkSecondsToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :max_walk_seconds, :integer
    add_column :trips, :min_walk_seconds, :integer
    add_column :trips, :max_total_seconds, :integer
    add_column :trips, :min_total_seconds, :integer
  end
end
