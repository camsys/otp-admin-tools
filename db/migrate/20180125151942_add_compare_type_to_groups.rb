class AddCompareTypeToGroups < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :compare_type, :string
    Group.reset_column_information
    Group.update_all(compare_type: 'atis')
  end
end
