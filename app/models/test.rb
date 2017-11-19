class Test < ApplicationRecord
  belongs_to :group
  has_many :trips, through: :group
  has_many :results

  def get_percent_matched

    # Calculate Percent Matched for Any Results that hasn't been done for.
    missing_percents = self.results.where(percent_matched: nil)
    missing_percents.each { |result| result.get_percent_matched }
    matching_array = self.results.map{ |result| result.percent_matched }

    return matching_array.sum.to_f/matching_array.count 

  end
end