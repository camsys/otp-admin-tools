class AddMode < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :otp_mode, :string
    add_column :tests, :atis_mode, :string
    add_column :groups, :otp_mode, :string
    add_column :groups, :atis_mode, :string
  end
end
