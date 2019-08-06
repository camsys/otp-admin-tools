module Stations

  require 'net/http'
  require 'json'


  class StationsController < ApplicationController

    def index
      # @stops = get_stations_from_api

      get_station_from_api

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


    def get_station_from_api()
      # TODO get the API key from anywhere else... Get the Stop ID from a list of stop IDs, get the date and time from UI elements.
      resp = uri_requesting('http://otp-mta-qa.camsys-apps.com/otp/routers/default/stationConnectivity?stopId=MTASBWY:211N&apikey=EQVQV8RM6R4o3Dwb6YNWfg6OMSR7kT9L')

      data = JSON.parse(resp.body)

      nodes = data['nodes'].map { |nd| StationNode.new(nd['id'], nd['lat'], nd['lon'], nd['type'], nd['wayId'], nd['isAccessible'])}
      # nodes = data['alerts'].map { |nd| StationNode.new(nd['id'], nd['lat'], nd['lon'], nd['type'], nd['wayId'], nd['isAccessible'])}
      links = data['links'].map { |nd| StationLink.new(nd['id'], nd['equipmentId'], nd['source'], nd['destination'], nd['type'], nd['pathwayCode'], nd['isActive'])}

      @station = Station.new(data['stationName'], data['stationId'], nodes, data['alerts'], links)

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