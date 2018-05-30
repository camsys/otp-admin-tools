class AddOtpModeToTrip < ActiveRecord::Migration[5.0]
  def change
    add_column :trips, :otp_mode, :string, null: false, default: 'WALK,TRANSIT'
  end
end
