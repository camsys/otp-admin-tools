class Group < ApplicationRecord

  has_many :trips
  has_many :tests

  #### METHODS ####
  
  def run_test
    otp = OtpService.new
    test = Test.create(group: self)
    test.comment = test.id 
    test.save 
    test.trips.each do |trip|
      request, response = otp.plan([trip.origin_lat, trip.origin_lng], [trip.destination_lat, trip.destination_lng], trip.time, arriveBy=trip.arrive_by, mode="TRANSIT,WALK")
      viewable = otp.viewable_url([trip.origin_lat, trip.origin_lng], [trip.destination_lat, trip.destination_lng], trip.time, arriveBy=trip.arrive_by, mode="TRANSIT,WALK")
      Result.create(trip: trip, test: test, otp_request: request, otp_response: response, otp_viewable_request: viewable)
    end
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
    self.trips.delete_all
    line = 2 #Line 1 is the header, start with line 2 in the count
    begin
      CSV.foreach(trips_file, {:col_sep => ",", :headers => true}) do |row|

        begin
          #If we have already created this Landmark, don't create it again.
          Trip.create!({
            origin: row[0],
            destination: row[1],
            time: "#{row[2]} #{row[3]}",
            arrive_by: row[4],
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
      self.geocode_trips
      return true, self.trips.count.to_s + " trips loaded"
    end

  end #Update
end
