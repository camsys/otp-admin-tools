class Trip < ApplicationRecord

  before_save :remove_semicolons

  belongs_to :group
  has_many   :results

  # For testing
  attr_accessor :api_key, :service_name, :count_total, :count_plan, :count_nearby, :count_collector

  ### SCOPES ###

  # Return trips before or after a given date and time
  scope :from_datetime, -> (datetime) { datetime ? where('trip_time >= ?', datetime) : all }
  scope :to_datetime, -> (datetime) { datetime ? where('trip_time <= ?', datetime) : all }
  
  # Rounds to beginning or end of day.
  scope :from_date, -> (date) { date ? from_datetime(date.in_time_zone.beginning_of_day) : all }
  scope :to_date, -> (date) { date ? to_datetime(date.in_time_zone.end_of_day) : all }

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
      atis_mode: self.atis_mode || "BCXTFRSLK123",
      otp_mode: self.otp_mode


    }
  end

  def remove_semicolons
    self.otp_mode.gsub!(';',',')
  end

end
