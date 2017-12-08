class AddOtpToTest < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :otp_walk_speed, :decimal
    add_column :tests, :otp_max_walk_distance, :decimal 
    add_column :tests, :otp_walk_reluctance, :decimal
    add_column :tests, :otp_transfer_penalty, :decimal
    add_column :groups, :otp_walk_speed, :decimal
    add_column :groups, :otp_max_walk_distance, :decimal 
    add_column :groups, :otp_walk_reluctance, :decimal
    add_column :groups, :otp_transfer_penalty, :decimal
  end
end
