class AddConfigToTest < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :otp_transfer_slack, :integer, null: false, default: 120
    add_column :tests, :otp_allow_unknown_transfers, :boolean, null: false, default: false
    add_column :tests, :otp_use_unpreferred_routes_penalty, :integer, null: false, default: 1200
    add_column :tests, :otp_use_unpreferred_start_end_penalty, :integer, null: false, default: 3600
    add_column :tests, :otp_other_than_preferred_routes_penalty, :integer, null: false, default: 10800
    add_column :tests, :otp_car_reluctance, :decimal, null: false, default: 4
    add_column :tests, :otp_path_comparator, :string, null: false, default: 'mta'
    add_column :tests, :otp_max_walk_distance_heuristic, :integer, null: false, default: 8047
  end
end
