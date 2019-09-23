require 'logger'
module ComparisonTools

  include TrapezeTools

  def get_otp_summary otp_response

    summary = []
    if otp_response["plan"]
      otp_response["plan"]["itineraries"].each do |itin|
        routes = []
        route_ids = []
        itin["legs"].each do |leg|
          unless leg["route"].blank?
            routes << leg["route"]
            route_ids << leg["routeId"]
          end
        end

        fare = itin.try(:[],'fare').try(:[], 'fare').try(:[],'regular').try(:[],'cents')

        summary << {duration: itin["duration"], 
                    start_time: itin["startTime"], 
                    end_time: itin["endTime"], 
                    walk_time: itin["walkTime"], 
                    drive_time: itin["driveTime"],
                    bike_time: itin["bikeTime"],
                    transit_time: itin["transitTime"], 
                    waiting_time: itin["waitingTime"],
                    walk_distance: itin["walkDistance"],
                    transfers: itin["transfers"],
                    routes: routes,
                    route_ids: route_ids,
                    legs: itin["legs"],
                    fare: (fare && fare >= 0) ? fare : nil
                    }
      end
    end

    return summary 

  end

  def otp_summary
    get_otp_summary self.otp_response
  end

  def otp2_summary
    get_otp_summary self.compare_response
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
                    legs: legs,
                    fare: itin['Regularfare'] ? ((itin['Regularfare'].to_f)*100).to_i : nil
        }
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

    if self.compare_type == 'baseline'
      return get_baseline_percent_matched 
    end

    otp_routes = (self.otp_summary.map{ |i| i[:route_ids] }).uniq

    if(self.compare_type == 'atis')
      compare_routes = (self.atis_summary.map{ |i| i[:route_ids] }).uniq
    elsif self.compare_type == 'otp'
      compare_routes = (self.otp2_summary.map{ |i| i[:route_ids] }).uniq
    end

    # If ATIS AND OTP return empty routes
    if compare_routes.empty? and otp_routes.empty?
      self.percent_matched = nil
      self.save
      return self.percent_matched
    end

    # If ATIS or OTP return empty routes
    if compare_routes.empty? || otp_routes.empty?
      self.percent_matched = 0
      self.save
      return self.percent_matched
    end

    #Convert the ATIS Route IDs to GTFS Ids
    if(self.compare_type == 'atis')
      mapping = Config.atis_otp_mapping
      mapped_otp_routes = []
      otp_routes.each do |itinerary|
        this_itin = []
        itinerary.each do |route|
           this_itin << (mapping[route.to_sym].nil? ? 'MAP MISSING' : mapping[route.to_sym].map{ |x| x[:atis_id]})
        end
        mapped_otp_routes << this_itin
      end
    else
      mapped_otp_routes = otp_routes
    end

    match = 0.0

    compare_routes.each do |route|
      match += 1 if match? route, mapped_otp_routes
    end
    self.percent_matched = match.to_f/compare_routes.count
    self.save
    return self.percent_matched

  end

  def compare_summary
    if self.compare_type == 'atis'
      compare_atis_summary
    elsif self.compare_type == 'otp'
      compare_otp_summary
    else
      compare_baseline_summary
    end
  end

  def compare_atis_summary
    if self.parsed_atis_response.nil? && self.compare_type == 'atis'
      return {walk_time: 'atis_nil', total_time: 'atis_nil', transfer: 'atis_nil', fare: 'atis_nil'}
    end

    if self.otp_response["plan"].nil?
      return {walk_time: 'otp_nil', total_time: 'otp_nil', transfer: 'otp_nil', fare: 'otp_nil'}
    end


    atis = arrayify(self.parsed_atis_response["Itin"]).first
    otp = self.otp_response["plan"]["itineraries"].first

    walk_time = (otp["walkTime"]/60.0).round.to_f - (atis["Walktime"]).to_f
    total_time_ratio = ((otp["duration"]/60.0).round.to_f/(atis["Totaltime"]).to_f) - 1
    transfers_ratio = otp["transfers"] - self.atis_summary.first[:transfers]

    fare = otp.try(:[],'fare').try(:[], 'fare').try(:[],'regular').try(:[],'cents')

    if fare && fare >= 0
      if self.atis_summary.first[:fare]
        fare_ratio = fare - self.atis_summary.first[:fare]
      else
        fare_ratio = 'atis_nil'
      end
    else
      fare_ratio = 'otp_nil'
    end

    return {walk_time: walk_time, total_time: total_time_ratio, transfer: transfers_ratio, fare: fare_ratio}
  end

  def compare_otp_summary

    if self.compare_response["plan"].nil?
      return {walk_time: 'otp2_nil', total_time: 'otp2_nil', transfer: 'otp2_nil', fare: 'otp2_nil'}
    end

    if self.otp_response["plan"].nil?
      return {walk_time: 'otp_nil', total_time: 'otp_nil', transfer: 'otp_nil', fare: 'otp_nil'}
    end

    otp2 = self.compare_response["plan"]["itineraries"].first
    otp = self.otp_response["plan"]["itineraries"].first


    walk_time = (otp["walkTime"]/60.0).round.to_f - (otp2["walkTime"]/60.0).round.to_f
    total_time_ratio = ((otp["duration"]).to_f/(otp2["duration"]).to_f) - 1
    transfers_ratio = otp["transfers"] - otp2["transfers"]

    fare = otp.try(:[],'fare').try(:[], 'fare').try(:[],'regular').try(:[],'cents')
    fare2 = otp2.try(:[],'fare').try(:[], 'fare').try(:[],'regular').try(:[],'cents')
    if fare && fare >= 0
      if fare2 && fare2 >= 0
        fare_ratio = fare - fare2
      else
        fare_ratio = 'otp2_nil'
      end
    else
      fare_ratio = 'otp_nil'
    end

    return {walk_time: walk_time, total_time: total_time_ratio, transfer: transfers_ratio, fare: fare_ratio}
  end

  def match? compare_route, mapped_otp_routes

    mapped_otp_routes.each do |otp_route|
      matched = true

      #Check for Length
      if otp_route.count != compare_route.count
        next
      end

      if(self.compare_type == 'atis')
        # Check for all matching legs
        # Some OTP Routes have multiple options,
        # which is why we have to check each leg individually
        otp_route.each_with_index do |leg, i|
          unless compare_route[i].in? leg
            matched = false
            break
          end
        end
      else
        otp_route.each_with_index do |leg, i|
          unless compare_route[i].in? leg
            matched = false
            break
          end
        end
      end
      if matched
        return true
      end
    end

      return false

  end

  def getQuantityText value
    if value < 0
      return "less"
    else
      return "more"
    end

  end


  def get_baseline_percent_matched
    if self.percent_matched
      return self.percent_matched
    end
    return get_baseline_stats.first 
  end

  def compare_baseline_summary
    return get_baseline_stats.last 
  end

  #BASELINE Tests
  def get_baseline_stats
    # WE ONLY CARE ABOUT THE FIRST ITINERARY
    total_tests = 0.0
    passing_tests = 0.0
    summary_hash = {}
    summary = self.otp_summary.first  

    trip = self.trip 

    # ERP Test
    unless trip.expected_route_pattern.blank?
      total_tests += 1.0

      #Confirm that we have at least 1 itinerary
      if summary.nil? 
        summary_hash[:erp] =  false
      else
        otp_routes = summary[:route_ids]
        if self.trip.expected_route_pattern.split(' ') == otp_routes 
           passing_tests += 1.0
           summary_hash[:erp] = true
        else
           summary_hash[:erp] = false
        end
      end

    end

    # Max Walk Test
    unless trip.max_walk_seconds.blank?
      total_tests += 1.0
      #Confirm that we have at least 1 itinerary
      if summary.nil? 
        summary_hash[:max_walk_seconds] =  false
      else
        if summary[:walk_time] <= trip.max_walk_seconds
          passing_tests += 1.0
          summary_hash[:max_walk_seconds] = true
        else
           summary_hash[:max_walk_seconds] = false
        end
      end
    end 

    # Min Walk Test
    unless trip.min_walk_seconds.blank?
      total_tests += 1.0
      #Confirm that we have at least 1 itinerary
      if summary.nil? 
        summary_hash[:min_walk_seconds] =  false
      else
        if summary[:walk_time] >= trip.min_walk_seconds
          passing_tests += 1.0
          summary_hash[:min_walk_seconds] = true
        else
           summary_hash[:min_walk_seconds] = false
        end
      end
    end 

    # Max Duration Test
    unless trip.max_total_seconds.blank?
      total_tests += 1.0
      #Confirm that we have at least 1 itinerary
      if summary.nil? 
        summary_hash[:max_total_seconds] =  false
      else
        if summary[:duration] <= trip.max_total_seconds
          passing_tests += 1.0
          summary_hash[:max_total_seconds] = true
        else
           summary_hash[:max_total_seconds] = false
        end
      end
    end 

    # Min Duration Test
    unless trip.min_total_seconds.blank?
      total_tests += 1.0
      #Confirm that we have at least 1 itinerary
      if summary.nil? 
        summary_hash[:min_total_seconds] =  false
      else
        if summary[:duration] >= trip.min_total_seconds
          passing_tests += 1.0
          summary_hash[:min_total_seconds] = true
        else
           summary_hash[:min_total_seconds] = false
        end
      end
    end 

    total_tests > 0 ? self.percent_matched = passing_tests/total_tests : self.percent_matched = 1
    self.save 
    return self.percent_matched, summary_hash
  end

end