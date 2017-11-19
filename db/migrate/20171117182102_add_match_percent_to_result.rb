class AddMatchPercentToResult < ActiveRecord::Migration[5.0]
  def change
    add_column :results, :percent_matched, :decimal 
  end
end
