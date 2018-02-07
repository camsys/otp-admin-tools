class AddExpectedRoutePatternToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :expected_route_pattern, :string
  end
end
