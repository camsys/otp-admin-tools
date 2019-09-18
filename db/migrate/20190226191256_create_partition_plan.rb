class CreatePartitionPlan < ActiveRecord::Migration
  def up
	# Create a schema plans_partitions, within which to store Plan partitions:
	Plan.create_infrastructure

	# Create partition tables with increments of one week:
	dates = Plan.partition_generate_range(Date.parse('2019-01-01'), Date.parse('2019-12-31'))
	Plan.create_new_partition_tables(dates)
  end

  def down
    Plan.delete_infrastructure
  end
end
