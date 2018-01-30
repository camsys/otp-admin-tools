class RenameAtisResponseToCompareResponse < ActiveRecord::Migration[5.0]
  def change
    rename_column :results, :atis_response, :compare_response
  end
end
