class Trip < ApplicationRecord

  belongs_to :group
  has_many   :results

  before_save :clean_expected_route_pattern

  def params trip_time=self.time
    {
      origin: {lat: self.origin_lat, lng: self.origin_lng},
      destination: {lat: self.destination_lat, lng: self.destination_lng}, 
      time: trip_time,
      arrive_by: self.arrive_by,
      atis_minimize: self.group.atis_minimize || "T",
      atis_walk_dist: self.group.atis_walk_dist || 1609.34,
      atis_walk_speed: self.group.atis_walk_speed || 1.34112,
      atis_accessible: self.atis_accessible || false,
      atis_mode: self.atis_mode || "BCXTFRSLK123"
    }
  end

  # Remove Spaces from ERP
  def clean_expected_route_pattern
    unless self.expected_route_pattern.nil? 
      self.expected_route_pattern = self.expected_route_pattern.gsub(' ', '')
    end
  end

end
