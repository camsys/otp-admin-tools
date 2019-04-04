class CreatePartitionPlanLocation < ActiveRecord::Migration
  def up
	# Create a schema plan_locations_partitions, within which to store PlanLocation partitions:
	PlanLocation.create_infrastructure

	# Create partition tables with increments of one week:
	dates = PlanLocation.partition_generate_range(Date.parse('2019-01-01'), Date.parse('2019-12-31'))
	PlanLocation.create_new_partition_tables(dates)
  end

  def down
    PlanLocation.delete_infrastructure
  end
end
