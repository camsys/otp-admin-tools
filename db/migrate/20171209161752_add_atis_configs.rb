class AddAtisConfigs < ActiveRecord::Migration[5.0]
  def change
    add_column :tests, :atis_minimize, :string
    add_column :tests, :atis_walk_dist, :decimal 
    add_column :tests, :atis_walk_speed, :decimal
    add_column :tests, :atis_walk_increase, :string
    add_column :groups, :atis_minimize, :string
    add_column :groups, :atis_walk_dist, :decimal 
    add_column :groups, :atis_walk_speed, :decimal
    add_column :groups, :atis_walk_increase, :string
  end
end
