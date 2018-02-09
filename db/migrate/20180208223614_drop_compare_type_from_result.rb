class DropCompareTypeFromResult < ActiveRecord::Migration[5.0]
  def change
    remove_column :results, :compare_type
  end
end
