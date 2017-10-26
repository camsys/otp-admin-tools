class Result < ApplicationRecord
  belongs_to :trip
  has_one :test, through: :trip

  serialize :otp_response

  def otp_summary
    summary = []
    if self.otp_response["plan"]
      self.otp_response["plan"]["itineraries"].each do |itin|
        summary << {duration: itin["duration"], 
                    start_time: itin["startTime"], 
                    end_time: itin["endTime"], 
                    walk_time: itin["walkTime"], 
                    transit_time: itin["transitTime"], 
                    waiting_time: itin["waitingTime"],
                    walk_distance: itin["walkDistance"],
                    transfers: itin["transfers"]}
      end
    end

    return summary 

  end

end
