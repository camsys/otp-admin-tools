module Stations

  require 'net/http'
  require 'json'


  class StationsController < AdminController
    def index
      sn = StationNode
      sl = StationLink
      st = Station


      # @stops = get_stations_from_api

      #make_station_api_request

      respond_to do |format|
        format.html
        format.json { render json: @station }
      end
    end

    def create

    end

    def get_stations_from_api
      resp = uri_requesting('http://otp-mta-qa.camsys-apps.com/otp/routers/default/index/stops?apikey=EQVQV8RM6R4o3Dwb6YNWfg6OMSR7kT9L')
      data = JSON.parse(resp.body)

      stop = data.map {|stop| OtpStop.new(stop['id'], stop['name'], stop['lat'], stop['lon'], stop['cluster'])}
    end

    def make_station_api_request()

      if params[:station_vis_station_id].present?
        station_vis_station_id =  'stopId='+params[:station_vis_station_id]
      else
        station_vis_station_id =  'stopId='+'MTASBWY:A32N'
      end
      if params[:station_vis_otp_date].present?
        station_vis_otp_date =  '&date='+params[:station_vis_otp_date]
      else
        station_vis_otp_date = nil
      end
      if params[:station_vis_start_time].present?
        station_vis_start_time = '&time='+params[:station_vis_start_time]
      else
        station_vis_start_time = nil
      end

      if params[:station_vis_station_viz_url].present?
        Config.station_viz_url = params[:station_vis_station_viz_url]
      end

      if params[:station_vis_station_viz_api_key].present?
        Config.station_viz_api_key = params[:station_vis_station_viz_api_key]
      end

      base_url = Config.station_viz_url
      api_key = Config.station_viz_api_key

      url = "#{base_url}/stationConnectivity?#{station_vis_station_id}#{station_vis_otp_date}#{station_vis_start_time}&apikey=#{api_key}"
      
      resp = uri_requesting(url)

      data = JSON.parse(resp.body)

      nodes = data['nodes'].map { |nd| StationNode.new(nd['id'], nd['label'], nd['lat'], nd['lon'], nd['type'], nd['osmWayId'], nd['accessible'])}
      alerts = data['alerts'].map { |nd| StationAlert.new(nd['alertHeaderText'], nd['alertDescription'], nd['alertUrl'])}
      links = data['links'].map { |nd| StationLink.new(nd['id'], nd['equipmentId'], nd['sourceId'], nd['destinationId'], nd['type'], nd['pathwayCode'], nd['active'])}

      @station = Station.new(data['stationName'], data['stationId'], nodes, alerts, links)
    end

    def get_station_from_api()
      result = make_station_api_request

      respond_to do |format|
        format.json { render json: result.as_json }
      end
    end

    def uri_requesting(url_string)
      url = URI.parse(url_string)
      req = Net::HTTP::Get.new(url.to_s)
      resp = Net::HTTP.start(url.host, url.port) {|http|
        http.request(req)
      }
      puts resp.body
      resp
    end

    def get_station_nodes_and_edges_from_api()

    end
  
  end
end