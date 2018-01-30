class RenameAtisRequestToCompareRequest < ActiveRecord::Migration[5.0]
  def change
    rename_column :results, :atis_request, :compare_request
  end
end
