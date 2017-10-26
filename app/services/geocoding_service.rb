require 'indirizzo'

class GeocodingService

  def google_place_search query
    google_api.get('autocomplete/json') do |req|
      req.params['input']    = query
      req.params['key']      = ENV['GOOGLE_PLACES_API_KEY']
      req.params['location'] = Setting.map_center
      req.params['radius']   = Setting.google_radius_meters
      req.params['components'] = Setting.geocoder_components
    end
  end

  def google_api
    connection = Faraday.new('https://maps.googleapis.com/maps/api/place') do |conn|
      conn.response :json
      conn.adapter Faraday.default_adapter
    end
  end

  def geocode(raw_address)
    Rails.logger.info "GEOCODE #{raw_address}"
    if raw_address.blank?
      return false, nil
    end
    begin
      res = Geocoder.search(raw_address, sensor: false, components: 'country:US', bounds: [[39.496227, -105.338796], [39.998374, -104.688062]])
      Rails.logger.info "# results from geocode: #{res.size}"
      Rails.logger.info "# results from geocode: #{res.ai}"
      results = process_results(res)
      Rails.logger.info "# results after processing: #{results.size}"
    rescue Exception => e
      Rails.logger.error format_exception(e)
      return false, nil
    end
    return true, results
  end

  def reverse_geocode(lat, lon)
    Rails.logger.debug "GEOCODE #{[lat, lon]}"
    raw_address = [lat, lon]
    begin
      res = Geocoder.search(raw_address)
      results = process_results(res)
    rescue Exception => e
      Rails.logger.error format_exception(e)
      return false, nil
    end
    return true, results
  end

  #Takes in results from geocode or reverse_geocode
  def get_street_address(results)
    results = results.last
    result = results.first
    if result
      return result[:street_address]
    else
      return nil
    end
  end


  def process_results(res)
    i = 0
    results  = []
    res.each do |alt|
      street_address = alt.street_address
      formatted_address = alt.formatted_address
      parsable_address = Indirizzo::Address.new(formatted_address)
      unless parsable_address.nil?
        street_address = parsable_address.number.to_s + ' ' + parsable_address.street.first.titleize.to_s
        formatted_address = street_address.to_s + ', ' + alt.city.to_s + ', ' + alt.state_code.to_s + ' ' + alt.postal_code.to_s
      end

      results << {
          :id => i,
          :name => formatted_address.split(",")[0],
          :formatted_address => sanitize_formatted_address(formatted_address),
          :street_address => street_address,
          :city => alt.city,
          :state => alt.state_code,
          :zip => alt.postal_code,
          :lat => alt.latitude,
          :lon => alt.longitude,
          :county => alt.sub_state,
          :place_id => alt.place_id,
          :raw => alt
      }
      i += 1
    end
    results
  end

  def sanitize_formatted_address(addr)
    if addr.include?(", USA")
      return addr[0..-6]
    else
      return addr
    end
  end


end