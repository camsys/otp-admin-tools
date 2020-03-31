class CreatePartitionPlanLocation2020 < ActiveRecord::Migration[5.0]
  def up
	# Create partition tables with increments of one week:
	dates = PlanLocation.partition_generate_range(Date.parse('2020-01-06'), Date.parse('2020-12-31'))
	PlanLocation.create_new_partition_tables(dates)
  end

  def down
  	# Don't want to drop tables containing data when reversing migration.
  	raise ActiveRecord::IrreversibleMigration
  	# Here is the command if needed.
    # dates = PlanLocation.partition_generate_range(Date.parse('2020-01-06'), Date.parse('2020-12-31'))
	# PlanLocation.drop_partition_tables(dates)
  end
end
