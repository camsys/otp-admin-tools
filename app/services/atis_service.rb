require "net/http"

class AtisService

  ## Format of trip_params ##  
  # {
  #   origin: {lat: self.origin_lat, lng: self.origin_lng},
  #   destination: {lat: self.destination_lat, lng: self.destination_lng}, 
  #   time: self.time,
  #   arrive_by: self.arrive_by
  # }

  attr_accessor :app_id, :base_url

  def initialize(base_url, app_id)
      @app_id = app_id
      @base_url = base_url
  end

  ## Send the Requests
  def plan_trip trip_params
    
    type = 'post'
    url = @base_url
    uri = URI.parse(url)
    case type.downcase
      when 'post'
        req = Net::HTTP::Post.new(uri.path)
        req.body = plan_body trip_params
      when 'delete'
        req = Net::HTTP::Delete.new(uri.path)
      else
        req = Net::HTTP::Get.new(uri)
    end

    puts req.body 
    req.add_field 'Content-Type', 'text/xml'

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = false
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.start {|http| http.request(req)}
    return req.body, Hash.from_xml(resp.body)["Envelope"]["Body"]["PlantripResponse"]

  end

  def plan_body trip_params 
    "<?xml version='1.0' encoding='UTF-8'?>
    <SOAP-ENV:Envelope xmlns:xsi='http://www.w3.org/1999/XMLSchema-instance' xmlns:SOAP-ENC='http://schemas.xmlsoap.org/soap/encoding/' xmlns:SOAP-ENV='http://schemas.xmlsoap.org/soap/envelope/' xmlns:xsd='http://www.w3.org/1999/XMLSchema' SOAP-ENV:encodingStyle='http://schemas.xmlsoap.org/soap/encoding/'>
    <SOAP-ENV:Body>
    <namesp1:Plantrip xmlns:namesp1='NY_SOAP2'>
      <Appid>#{@app_id}</Appid>
      <Originlat>#{trip_params[:origin][:lat]}</Originlat>
      <Originlong>#{trip_params[:origin][:lng]}</Originlong>
      <Origintext>Origin Name</Origintext>
      <Destinationlat>#{trip_params[:destination][:lat]}</Destinationlat>
      <Destinationlong>#{trip_params[:destination][:lng]}</Destinationlong>
      <Destinationtext>Destination Name</Destinationtext>
      <Time>1357</Time>
      <Date>11/25/17</Date>
      <Minimize>T</Minimize>
      <Accessible>N</Accessible>
      <Arrdep>A</Arrdep>
      <Walkdist>1</Walkdist>
      <Walkspeed>5</Walkspeed>
      <Walkincrease>Y</Walkincrease>
      <Maxanswers>3</Maxanswers>
      <Maxtransfers>3</Maxtransfers>
      <Debug>1</Debug>
      <Xmode>BCXTFRSLK123</Xmode>
    </namesp1:Plantrip>
    </SOAP-ENV:Body>
    </SOAP-ENV:Envelope>"
  end

  def plan(from,
      to, trip_datetime, arriveBy=true, mode="TRANSIT,WALK", wheelchair="false", walk_speed=3.0,
      max_walk_distance=2, max_bicycle_distance=5, optimize='QUICK', num_itineraries=3,
      min_transfer_time=nil, max_transfer_time=nil, banned_routes=nil, preferred_routes=nil)


  end
end
 