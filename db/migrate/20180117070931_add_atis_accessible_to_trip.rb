class AddAtisAccessibleToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :atis_accessible, :boolean
  end
end
