module ComparisonTools

  include TrapezeTools

  def otp_summary

    summary = []
    if self.otp_response["plan"]
      self.otp_response["plan"]["itineraries"].each do |itin|
        routes = []
        route_ids = []
        itin["legs"].each do |leg|
          unless leg["route"].blank?
            routes << leg["route"]
            route_ids << leg["routeId"]
          end
        end
        summary << {duration: itin["duration"], 
                    start_time: itin["startTime"], 
                    end_time: itin["endTime"], 
                    walk_time: itin["walkTime"], 
                    transit_time: itin["transitTime"], 
                    waiting_time: itin["waitingTime"],
                    walk_distance: itin["walkDistance"],
                    transfers: itin["transfers"],
                    routes: routes,
                    route_ids: route_ids,
                    legs: itin["legs"]}
      end
    end

    return summary 

  end

  def atis_summary
    summary = []

    itineraries = self.parsed_atis_response.nil? ? [] : (arrayify self.parsed_atis_response["Itin"])

    itineraries.each do |itin|
      routes = []

      if itin["Legs"] 
        legs = arrayify itin["Legs"]["Leg"]
        routes  = []
        route_ids  = []
        legs.each do |value|
          unless value["Service"].blank? 
            routes << value["Service"]["Publicroute"]
            route_ids << value["Service"]["Route"]
          end
        end

        summary << {duration: itin["Totaltime"].to_f*60, 
                    start_time: atis_start_time(itin), 
                    end_time: atis_end_time(itin),
                    walk_time: itin["Walktime"].to_f*60, 
                    transit_time: itin["Transittime"].to_f*60, 
                    waiting_time: nil,
                    walk_distance: nil,
                    transfers: [routes.count - 1, 0].max,
                    routes: routes,
                    route_ids: route_ids,
                    legs: legs}
      end
    end

    return summary 

  end

  def atis_start_time itin 
    #Atis doesn't give a start time or end time
    #You have to find it by adding walk times to the first/last legs
    legs = arrayify itin["Legs"]["Leg"]
    board_time = legs.first["Ontime"].dup # Will be in this format HHMM as a string
    walk_time = legs.first["Onwalktime"] # Will be an integer representing minutes
    departure_time = board_time.insert(2, ':').to_time - walk_time.to_i.minutes #Get a time of boarding.  The date will be ignored
    departure_time.strftime('%H%M') # Return the departure time in the ATIS HHMM format.
  end

  def atis_end_time itin 
    #Atis doesn't give a start time or end time
    #You have to find it by adding walk times to the first/last legs
    legs = arrayify itin["Legs"]["Leg"]
    alight_time = legs.last["Offtime"].dup # Will be in this format HHMM as a string
    walk_time = itin["Finalwalktime"] # Will be an integer representing minutes
    arrive_time = alight_time.insert(2, ':').to_time + walk_time.to_i.minutes #Get a time of boarding.  The date will be ignored
    arrive_time.strftime('%H%M') # Return the departure time in the ATIS HHMM format.
  end

  def get_percent_matched

    return self.percent_matched if self.percent_matched


    otp_routes = (self.otp_summary.map{ |i| i[:route_ids] }).uniq
    atis_routes = (self.atis_summary.map{ |i| i[:route_ids] }).uniq

    # If ATIS or OTP return empty routes
    if atis_routes.empty? || otp_routes.empty?
      self.percent_matched = 0
      self.save
      return self.percent_matched
    end

    if atis_routes.empty? and otp_routes.empty?
      self.percent_matched = nil
      self.save
      return self.percent_matched
    end

    #Convert the ATIS Route IDs to GTFS Ids
    mapping = Config.atis_otp_mapping
    mapped_otp_routes = []
    otp_routes.each do |itinerary|
      this_itin = []
      itinerary.each do |route|
         this_itin << (mapping[route.to_sym].nil? ? 'MAP MISSING' : mapping[route.to_sym].map{ |x| x[:atis_id]})
      end
      mapped_otp_routes << this_itin
    end

    match = 0.0

    atis_routes.each do |route|
      match += 1 if match? route, mapped_otp_routes
    end
    self.percent_matched = match.to_f/atis_routes.count 
    self.save
    return self.percent_matched

  end

  def compare_summary
    
    if self.parsed_atis_response.nil?
      return {walk_time: 'atis_nil', transit_time: 'atis_nil', transfer: 'atis_nil'}
    end

    if self.otp_response["plan"].nil?
      return {walk_time: 'otp_nil', transit_time: 'otp_nil', transfers: 'otp_nil'}
    end

    atis = arrayify(self.parsed_atis_response["Itin"]).first 
    otp = self.otp_response["plan"]["itineraries"].first


    walk_time_ratio = ((otp["walkTime"]/60.0).round.to_f/(atis["Walktime"]).to_f) - 1
    total_time_ratio = ((otp["duration"]/60.0).round.to_f/(atis["Totaltime"]).to_f) - 1
    transfers_ratio = otp["transfers"] - self.atis_summary.first[:transfers]

    return {walk_time: walk_time_ratio, total_time: total_time_ratio, transfer: transfers_ratio}
  end

  def match? atis_route, mapped_otp_routes

    mapped_otp_routes.each do |otp_route|
      matched = true
      
      #Check for Length
      if otp_route.count != atis_route.count
        next
      end

      # Check for all matching legs 
      # Some OTP Routes have multiple options, 
      # which is why we have to check each leg individually 
      otp_route.each_with_index do |leg, i|
        unless atis_route[i].in? leg
          matched = false 
          break
        end
      end
      if matched 
        return true
      end
    end

    return false

  end
end