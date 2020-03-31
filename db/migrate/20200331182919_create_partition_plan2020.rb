class CreatePartitionPlan2020 < ActiveRecord::Migration[5.0]
  def up
    # Create partition tables with increments of one week:
	dates = Plan.partition_generate_range(Date.parse('2020-01-06'), Date.parse('2020-12-31'))
	Plan.create_new_partition_tables(dates)
  end

  def down
  	# Don't want to drop tables containing data when reversing migration. 
  	raise ActiveRecord::IrreversibleMigration
    # Here is the command if needed.
    # dates = Plan.partition_generate_range(Date.parse('2020-01-06'), Date.parse('2020-12-31'))
	# Plan.drop_partition_tables(dates)
  end
end
