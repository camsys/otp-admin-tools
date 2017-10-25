class AddSetToTrip < ActiveRecord::Migration[5.0]
  def change

    add_reference :trips, :group, index: true

  end
end
