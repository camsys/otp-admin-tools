class ByPlanRequestTime < Partitioned::ByWeeklyTimeField
  self.abstract_class = true

  def self.partition_time_field
    return :plan_request_time
  end
end

class PlanLocation < ByPlanRequestTime

	belongs_to :plan, :class_name => 'Plan'
	belongs_to :from_location, class_name: 'Location', foreign_key: :from_category_id
    belongs_to :to_location, class_name: 'Location', foreign_key: :to_category_id

    partitioned do |partition|

    end

end