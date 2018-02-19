require 'csv'
class Group < ApplicationRecord

  include DateTools
  include OtpTools
  include TestTools

  has_many :trips
  has_many :tests

  GROUP_TYPES = {
      'atis' => 'OTP <-> Atis',
      'otp' => 'OTP <-> OTP',
      'baseline' => 'OTP <-> BASELINE'
  }

  #### METHODS ####

  def baseline?
    self.compare_type == 'baseline'
  end

  def otp?
    self.compare_type == 'otp'
  end

  def atis?
    self.compare_type == 'atis'
  end

  def geocode_trips
    geocoder = GeocodingService.new
    self.trips.each do |trip|
      
      #Geocode Origin
      unless trip.origin_lat and trip.origin_lng
        res = geocoder.geocode(trip.origin)
        if res.first #The first value is a true/false indicating success
          trip.origin_lat, trip.origin_lng = res[1].first[:lat], res[1].first[:lon]
        end
      end

      #Geocode Destination
      unless trip.destination_lat and trip.destination_lng
        res = geocoder.geocode(trip.destination)
        if res.first #The first value is a true/false indicating success
          trip.destination_lat, trip.destination_lng = res[1].first[:lat], res[1].first[:lon]
        end
      end
      trip.save
    end
  end

  # Load new Trips from CSV
  def update_trips file
    require 'open-uri'
    require 'csv'
    trips_file = open(file)

    # Iterate through CSV.
    failed = false
    message = ""
    #self.trips.delete_all
    line = 2 #Line 1 is the header, start with line 2 in the count
    begin
      CSV.foreach(trips_file, {:col_sep => ",", :headers => true}) do |row|

        begin
          Trip.create!({
               origin: row[0],
               origin_lat: row[1],
               origin_lng: row[2],
               destination: row[3],
               destination_lat: row[4],
               destination_lng: row[5],
               time: DateTime.strptime("#{row[6]} #{row[7]} -0500", "%m/%e/%y %l:%M %p %z"),
               arrive_by: row[8],
               atis_mode: row[9] || "BCXTFRSLK123",
               atis_accessible: row[10] || false,
               expected_route_pattern: row[11],
               min_walk_seconds: row[12],
               max_walk_seconds: row[13],
               min_total_seconds: row[14],
               max_total_seconds: row[15],
               group: self
           })

        rescue
          #Found an error, back out all changes and restore previous POIs
          message = 'Error found on line: ' + line.to_s
          Rails.logger.info message
          self.trips.delete_all
          failed = true
          break
        end
        line += 1
      end
    rescue
      failed = true
      message = 'Error Reading File'
      Rails.logger.info message
      self.trips.delete_all
      failed = true
    end

    if failed
      return false, message
    else
      return true, self.trips.count.to_s + " trips loaded"
    end

  end #Update

  def export_trips
    attributes = %w{origin origin_lat origin_lng destination destination_lat 
                    destination_lng trip_date trip_time arrive_by atis_mode 
                    atis_accessible expected_route_pattern min_walk_seconds 
                    max_walk_seconds min_total_seconds max_total_seconds} #customize columns here
    trips = Trip.where(group_id: self.id)

    CSV.generate(headers: true) do |csv|
      csv << attributes

      trips.each do |trip|
        csv << attributes.map{ |attr|
          if attr == 'trip_date'
            trip.time.strftime("%D")
          elsif attr == 'trip_time'
            trip.time.strftime("%I:%M %p")
          else
            trip.send(attr)
          end
        }
      end
    end
  end

  def formatted_type
    GROUP_TYPES[self.compare_type]
  end

end
