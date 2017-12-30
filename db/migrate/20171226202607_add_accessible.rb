class AddAccessible < ActiveRecord::Migration[5.0]
  def change
    add_column :groups, :otp_accessible, :boolean
    add_column :groups, :atis_accessible, :boolean
  end
end
