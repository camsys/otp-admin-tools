class AddTripTimeToResult < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :trip_time, :datetime
  end
end
