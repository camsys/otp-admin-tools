class AddTripToResult < ActiveRecord::Migration[5.0]
  def change
    add_reference :results, :trip, index: true
  end
end
