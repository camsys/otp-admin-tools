module OtpTools

  def otp_modes_from_atis atis_mode

    atis_mode ||= "BCXTFRSLK123"

    mode_types = {
        "B" => "MTABC,MTA NYCT",
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

      banned_modes = mode_types.keys - atis_mode.split("")
      banned_modes.each_with_index do |char|
        mode_key = char.upcase
        if mode_types.has_key?(mode_key)
          if(mode_key != 'X')
            banned_agencies.push(mode_types[mode_key])
          else
            banned_routes.push(mode_types[mode_key])
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

      banned_routes.each do |banned_route|
        banned_route_types_param = "#{banned_route}"
      end

    end
    return banned_agencies_param, banned_route_types_param
  end

end
