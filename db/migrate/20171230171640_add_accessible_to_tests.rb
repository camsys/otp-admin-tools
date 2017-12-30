class AddAccessibleToTests < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :otp_accessible, :boolean
    add_column :tests, :atis_accessible, :boolean
  end
end
