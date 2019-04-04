class ByRequestTime < Partitioned::ByWeeklyTimeField
  self.abstract_class = true

  def self.partition_time_field
    return :request_time
  end
end

class Plan < ByRequestTime

  has_many :plan_locations, dependent: :destroy
  belongs_to :type

  partitioned do |partition|
    partition.index :id, :unique => true
  end

end