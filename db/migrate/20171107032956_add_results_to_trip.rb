class AddResultsToTrip < ActiveRecord::Migration[5.0]
  def change
    add_reference :results, :test, index: true
  end
end
