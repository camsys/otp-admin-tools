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
                    route_ids: route_ids}
      end
    end

    return summary 

  end

  def atis_summary
    summary = []

    itineraries = self.atis_response.nil? ? [] : (arrayify self.atis_response["Itin"])

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
                    start_time: nil, 
                    end_time: nil,
                    walk_time: itin["Walktime"].to_f*60, 
                    transit_time: itin["Transittime"].to_f*60, 
                    waiting_time: nil,
                    walk_distance: nil,
                    transfers: [routes.count - 1, 0].max,
                    routes: routes,
                    route_ids: route_ids}
      end
    end

    return summary 

  end

  def get_percent_matched

    return self.percent_matched if self.percent_matched


    otp_routes = (self.otp_summary.map{ |i| i[:route_ids] }).uniq
    atis_routes = (self.atis_summary.map{ |i| i[:route_ids] }).uniq

    # If ATIS returned routes, but OTP did not
    if not atis_routes.empty? and otp_routes.empty?
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
         this_itin << (mapping[route.to_sym].nil? ? 'MAP MISSING' : mapping[route.to_sym][:atis_id])
      end
      mapped_otp_routes << this_itin
    end

    match = 0.0
    atis_routes.each do |route|
      match += 1 if route.in? mapped_otp_routes 
    end

    self.percent_matched = match.to_f/atis_routes.count 
    self.save
    return self.percent_matched

  end


  def compare_summary
    
    if self.atis_response.nil? 
      return {walk_time: 0, transit_time: 0, transfer: 0}
    end

    atis = arrayify(self.atis_response["Itin"]).first 
    otp = self.otp_response["plan"]["itineraries"].first 
    walk_time_ratio = (otp["walkTime"].to_f/(atis["Walktime"].to_f*60)) - 1
    total_time_ratio = (otp["duration"].to_f/(atis["Totaltime"].to_f*60)) - 1
    transfers_ratio = otp["transfers"] - self.atis_summary.first[:transfers]

    return {walk_time: walk_time_ratio, total_time: total_time_ratio, transfer: transfers_ratio}
  end
end