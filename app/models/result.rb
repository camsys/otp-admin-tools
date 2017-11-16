class Result < ApplicationRecord
  belongs_to :trip
  belongs_to :test

  serialize :otp_response
  serialize :atis_response

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

  def atis_summary
    summary = []
    if self.atis_response["Itin"].each do |itin|
      summary << {duration: itin["Totaltime"].to_f*60, 
                  start_time: nil, 
                  end_time: nil,
                  walk_time: itin["Walktime"].to_f*60, 
                  transit_time: itin["Transittime"].to_f*60, 
                  waiting_time: nil,
                  walk_distance: nil,
                  transfers: itin["Legs"].count,}
      end
    end

    return summary 

  end

  def compare_summary
    atis = self.atis_response["Itin"].first 
    otp = self.otp_response["plan"]["itineraries"].first 
    walk_time_ratio = otp["walkTime"].to_f/(atis["Walktime"].to_f*60)
    transit_time_ratio = otp["transitTime"].to_f/(atis["Transittime"].to_f*60)

    if (atis["Legs"].count == 0) and otp["transfers"] > 0
      transfers_ratio = "inf"
    elsif (atis["Legs"].count == 0) and otp["transfers"] == 0
      transfers_ratio = 1
    else
      transfers_ratio = otp["transfers"].to_f/(atis["Legs"].count.to_f)
    end

    return {walk_time: walk_time_ratio, transit_time: transit_time_ratio, transfer: transfers_ratio}
  end

end
