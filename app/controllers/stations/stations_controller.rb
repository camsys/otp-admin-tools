module Stations

  require 'net/http'
  require 'json'


  class StationsController < ApplicationController

    def index
      sn = StationNode
      sl = StationLink
      st = Station


      # @stops = get_stations_from_api

      make_station_api_request

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



      # TODO get the API key from anywhere else... Get the Stop ID from a list of stop IDs, get the date and time from UI elements.
      # resp = uri_requesting('http://otp-mta-qa.camsys-apps.com/otp/routers/default/stationConnectivity?stopId=MTASBWY:211N&apikey=EQVQV8RM6R4o3Dwb6YNWfg6OMSR7kT9L')
      # resp = uri_requesting("http://otp-mta-qa.camsys-apps.com/otp/routers/default/stationConnectivity?stopId=#{MTASBWY:A32N}&apikey=EQVQV8RM6R4o3Dwb6YNWfg6OMSR7kT9L")
      resp = uri_requesting("http://otp-mta-qa.camsys-apps.com/otp/routers/default/stationConnectivity?#{station_vis_station_id}#{station_vis_otp_date}#{station_vis_start_time}&apikey=EQVQV8RM6R4o3Dwb6YNWfg6OMSR7kT9L")

      data = JSON.parse(resp.body)

      nodes = data['nodes'].map { |nd| StationNode.new(nd['id'], nd['label'], nd['lat'], nd['lon'], nd['type'], nd['osmWayId'], nd['accessible'])}
      alerts = ['This is a test alert', 'This is a second alert with a longer more details message']
      # alerts = data['alerts'].map { |nd| StationNode.new(nd['id'], nd['lat'], nd['lon'], nd['type'], nd['wayId'], nd['isAccessible'])}
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