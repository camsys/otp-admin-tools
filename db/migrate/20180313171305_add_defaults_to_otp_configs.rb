class AddDefaultsToOtpConfigs < ActiveRecord::Migration[5.0]
  def change
    change_column :groups, :otp_walk_speed, :decimal, null: false, default: 1.3
    change_column :groups, :otp_max_walk_distance, :decimal, null: false, default: 8046.72
    change_column :groups, :otp_walk_reluctance, :decimal, null: false, default: 4
    change_column :groups, :otp_transfer_penalty, :decimal, null: false, default: 600
  end
end
