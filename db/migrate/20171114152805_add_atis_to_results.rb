class AddAtisToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :atis_request, :text
    add_column :results, :atis_response, :text
  end
end
