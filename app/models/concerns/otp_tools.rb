module OtpTools

  def otp_modes_from_atis atis_mode

    atis_mode = atis_mode.empty? ? "BCXTFRSLK123" : atis_mode

    mode_types = {
        "B" => "3",
        "R" => "MTASBWY",
        "C" => "LI,MNR",
        "F" => "NYC DOT,NYCWF",
        "X" => "702"
    }
    unassigned_modes = "NJT,NJB,path-nj-us,LIBUS"

    banned_agencies_param = nil
    banned_route_types_param = nil

    # Convert ATIS mode to OTP mode
    if atis_mode != "BCXTFRSLK123"

      banned_agencies = Array.new
      banned_routes = Array.new

      if atis_mode.length > 0
        banned_modes = mode_types.keys - atis_mode.split("")

        banned_modes.each_with_index do |char|
          mode_key = char.upcase
          if mode_types.has_key?(mode_key)
            if(mode_key == 'B')
              banned_routes.push(mode_types[mode_key])
            elsif(mode_key == 'X')
              banned_routes.push(mode_types[mode_key])
            else
              banned_agencies.push(mode_types[mode_key])
            end
          end
        end


        banned_agencies.each_with_index do |banned_agency, index|
          if(index == 0)
            banned_agencies_param = "#{unassigned_modes},#{banned_agency}"
          else
            banned_agencies_param += ",#{banned_agency}"
          end
        end

        banned_routes.each_with_index do |banned_route, index|
          if(index == 0)
            banned_route_types_param = "#{banned_route}"
          else
            banned_route_types_param += ",#{banned_route}"
          end
        end

      end

    end
    return banned_agencies_param, banned_route_types_param
  end

end
