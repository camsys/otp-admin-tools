class AddGroupToTest < ActiveRecord::Migration[5.0]
  def change
    add_reference :tests, :group, index: true
  end
end
