class AddAtisModeToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :atis_mode, :string
  end
end
