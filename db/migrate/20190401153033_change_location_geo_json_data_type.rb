class ChangeLocationGeoJsonDataType < ActiveRecord::Migration
  def change
  	  change_column :locations, :geojson, :text
  end
end
