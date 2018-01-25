class Group < ApplicationRecord

  include DateTools
  include OtpTools

  has_many :trips
  has_many :tests

  GROUP_TYPES = {
      'atis' => 'OTP <-> Atis',
      'otp' => 'OTP <-> OTP'
  }

  #### METHODS ####
  
  def run_test
    otp = OtpService.new(Config.otp_url, Config.otp_api_key)
    atis = AtisService.new(Config.atis_url, Config.atis_app_id)
    test = Test.create(group: self)

    # Copy params for archiving.
    # The group params may change in the future, but we shuld remember the params this particular
    # test was run with.
    test.otp_walk_speed = self.otp_walk_speed
    test.otp_max_walk_distance = self.otp_max_walk_distance
    test.otp_walk_reluctance = self.otp_walk_reluctance
    test.otp_transfer_penalty = self.otp_transfer_penalty
    test.atis_minimize = self.atis_minimize
    test.atis_walk_dist = self.atis_walk_dist
    test.atis_walk_speed = self.atis_walk_speed
    test.atis_walk_increase = self.atis_walk_increase
    #test.otp_accessible = self.otp_accessible
    #test.atis_accessible = self.atis_accessible

    test.comment = test.id
    test.save

    test.trips.each do |trip|

      trip_day_index = trip.time.wday
      raw_trip_date = get_non_holiday_date get_date_for_day(trip_day_index)
      raw_trip_time = trip.time.strftime("%l:%M %p %z")
      raw_trip_date_time = "#{raw_trip_date} #{raw_trip_time}"

      trip_time =  DateTime.strptime(raw_trip_date_time, "%Y-%m-%d %l:%M %p %z")
      
      if trip_time < DateTime.now
      	trip_time += 7.days
      end

      otp_banned_agencies, otp_banned_route_types = otp_modes_from_atis(trip.atis_mode)

      otp_request, otp_response =   otp.plan(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)

      atis_request, atis_response = atis.plan_trip(trip.params trip_time)

      viewable = otp.viewable_url(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)
      
      Result.create(trip: trip, test: test, 
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    atis_request: atis_request, atis_response: atis_response, trip_time: trip_time)
    end
  end

  def run_otp_test
    otp = OtpService.new(Config.otp_url, Config.otp_api_key)
    otp2 = OtpService.new(Config.otp2_url, Config.otp2_api_key)
    test = Test.create(group: self)

    # Copy params for archiving.
    # The group params may change in the future, but we shuld remember the params this particular
    # test was run with.
    test.otp_walk_speed = self.otp_walk_speed
    test.otp_max_walk_distance = self.otp_max_walk_distance
    test.otp_walk_reluctance = self.otp_walk_reluctance
    test.otp_transfer_penalty = self.otp_transfer_penalty

=begin
    test.atis_minimize = self.atis_minimize
    test.atis_walk_dist = self.atis_walk_dist
    test.atis_walk_speed = self.atis_walk_speed
    test.atis_walk_increase = self.atis_walk_increase
=end
    #test.otp_accessible = self.otp_accessible
    #test.atis_accessible = self.atis_accessible

    test.comment = test.id
    test.save

    test.trips.each do |trip|

      trip_day_index = trip.time.wday
      raw_trip_date = get_non_holiday_date get_date_for_day(trip_day_index)
      raw_trip_time = trip.time.strftime("%l:%M %p %z")
      raw_trip_date_time = "#{raw_trip_date} #{raw_trip_time}"

      trip_time =  DateTime.strptime(raw_trip_date_time, "%Y-%m-%d %l:%M %p %z")

      if trip_time < DateTime.now
        trip_time += 7.days
      end

      otp_banned_agencies, otp_banned_route_types = otp_modes_from_atis(trip.atis_mode)

      otp_request, otp_response =   otp.plan(
          [trip.origin_lat, trip.origin_lng],
          [trip.destination_lat, trip.destination_lng],
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed,
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)

      otp2_request, otp2_response =   otp2.plan(
          [trip.origin_lat, trip.origin_lng],
          [trip.destination_lat, trip.destination_lng],
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed,
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)

      viewable = otp.viewable_url(
          [trip.origin_lat, trip.origin_lng],
          [trip.destination_lat, trip.destination_lng],
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed,
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)

      viewable2 = otp2.viewable_url(
          [trip.origin_lat, trip.origin_lng],
          [trip.destination_lat, trip.destination_lng],
          trip_time, arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed,
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          tranfser_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types)

      Result.create(trip: trip, test: test,
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    atis_request: otp2_request, atis_response: otp2_response, trip_time: trip_time)
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

  def formatted_type
    GROUP_TYPES[self.compare_type]
  end

end
