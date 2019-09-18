class AddPlanRequestTimeToPlanLocation < ActiveRecord::Migration
  def change
  	add_column :plan_locations, :plan_request_time, :datetime
  end
end
