module TestTools

  def run_test
    case self.compare_type
    when 'atis'
      return run_atis_test
    when 'otp'
      return run_otp_test
    when 'baseline'
      return run_baseline_test
    end
  end
  
  def run_atis_test
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
    test.otp_transfer_slack = self.otp_transfer_slack
    test.otp_allow_unknown_transfers = self.otp_allow_unknown_transfers
    test.otp_use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty
    test.otp_use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty
    test.otp_other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty
    test.otp_car_reluctance = self.otp_car_reluctance
    test.otp_path_comparator = self.otp_path_comparator
    test.otp_max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
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
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
          )

      atis_request, atis_response = atis.plan_trip(trip.params trip_time)

      viewable = otp.viewable_url(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
          )
      
      Result.create(trip: trip, test: test, 
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    compare_request: atis_request, compare_response: atis_response, trip_time: trip_time)
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
    test.otp_transfer_slack = self.otp_transfer_slack
    test.otp_allow_unknown_transfers = self.otp_allow_unknown_transfers
    test.otp_use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty
    test.otp_use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty
    test.otp_other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty
    test.otp_car_reluctance = self.otp_car_reluctance
    test.otp_path_comparator = self.otp_path_comparator
    test.otp_max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic

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
          trip_time,
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
        )

      otp2_request, otp2_response =   otp2.plan(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
      )

      viewable = otp.viewable_url(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
      )

      puts viewable.ai 

      result = Result.create(trip: trip, test: test,
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    compare_request: otp2_request, compare_response: otp2_response, trip_time: trip_time)
    end
  end

  def run_baseline_test
    otp = OtpService.new(Config.otp_url, Config.otp_api_key)
    test = Test.create(group: self)

    # Copy params for archiving.
    # The group params may change in the future, but we shuld remember the params this particular
    # test was run with.
    test.otp_walk_speed = self.otp_walk_speed
    test.otp_max_walk_distance = self.otp_max_walk_distance
    test.otp_walk_reluctance = self.otp_walk_reluctance
    test.otp_transfer_penalty = self.otp_transfer_penalty
    test.otp_transfer_slack = self.otp_transfer_slack
    test.otp_allow_unknown_transfers = self.otp_allow_unknown_transfers
    test.otp_use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty
    test.otp_use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty
    test.otp_other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty
    test.otp_car_reluctance = self.otp_car_reluctance
    test.otp_path_comparator = self.otp_path_comparator
    test.otp_max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
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
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
        )

      viewable = otp.viewable_url(
          [trip.origin_lat, trip.origin_lng], 
          [trip.destination_lat, trip.destination_lng], 
          trip_time, 
          mode=trip.otp_mode,
          arriveBy=trip.arrive_by,
          walk_speed=self.otp_walk_speed, 
          max_walk_distance=self.otp_max_walk_distance,
          walk_reluctance=self.otp_walk_reluctance,
          transfer_penalty=self.otp_transfer_penalty,
          wheelchair=trip.atis_accessible, banned_agencies=otp_banned_agencies,
          banned_route_types=otp_banned_route_types,
          transfer_slack = self.otp_transfer_slack,
          allow_unknown_transfers = self.otp_allow_unknown_transfers,
          use_unpreferred_routes_penalty = self.otp_use_unpreferred_routes_penalty,
          use_unpreferred_start_end_penalty = self.otp_use_unpreferred_start_end_penalty,
          other_than_preferred_routes_penalty = self.otp_other_than_preferred_routes_penalty,
          car_reluctance = self.otp_car_reluctance,
          path_comparator = self.otp_path_comparator,
          max_walk_distance_heuristic = self.otp_max_walk_distance_heuristic
      )

      result = Result.create(trip: trip, test: test,
                    otp_request: otp_request, otp_response: otp_response, otp_viewable_request: viewable,
                    trip_time: trip_time)
    end
  end

end