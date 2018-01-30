class AddCompareTypeToResults < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :compare_type, :string
    Result.reset_column_information
    Result.update_all(compare_type: 'atis')
  end
end
