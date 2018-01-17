class RemoveMode < ActiveRecord::Migration[5.0]
  def change
    remove_column :tests, :otp_mode, :string
    remove_column :tests, :atis_mode, :string
    remove_column :groups, :otp_mode, :string
    remove_column :groups, :atis_mode, :string
  end
end
