require 'json'
require 'rgeo'
require 'rgeo/geo_json'

namespace :reports do

  desc "Load NYC counties as locations"
  task load_counties: :environment do

	file = File.read "lib/assets/new-york-counties.geojson"
	data = JSON.parse(file)
  geo_factory = RGeo::Cartesian.factory(uses_lenient_assertions: true)
  feature_collection = RGeo::GeoJSON.decode(data, geo_factory: geo_factory)

	nyc_counties = ['Bronx County', 'Kings County', 'New York County', 'Queens County', 'Richmond County']

	Location.where(category: 1).destroy_all
	feature_collection.each do |feature|
		if nyc_counties.include?(feature.property("name"))
			location = Location.new
			location.category = 1
			location.name = feature.property("name")
			location.geojson = feature.geometry
			location.save
		end
	end
  end

  desc "Load NYCT zones as locations"
  task load_transit_zones: :environment do

	file = File.read "lib/assets/TransitZones.geojson"
	data = JSON.parse(file)
  geo_factory = RGeo::Cartesian.factory(uses_lenient_assertions: true)
  feature_collection = RGeo::GeoJSON.decode(data, geo_factory: geo_factory)

	Location.where(category: 2).destroy_all
	feature_collection.each do |feature|
		location = Location.new
		location.category = 2
		location.name = "Zone " + feature.property("objectid_1")
		location.geojson = feature.geometry
		location.save

	end
  end

  desc "Update plan locations for plans requested recently and with no plan locations "
  task update_plan_locations_recent: :environment do
 	plans = Plan.where("request_time > ?", 365.days.ago).includes(:plan_locations).where(plan_locations: { id: nil }) 
 	update_plan_locations(plans)	
  end

  desc "Update plan locations for plans with no plan locations"
  task update_plan_locations_empty: :environment do
  	plans = Plan.includes(:plan_locations).where(plan_locations: { id: nil })
  	update_plan_locations(plans)
  end

  desc "Update plan locations for all plans"
  task update_plan_locations_all: :environment do
  	plans = Plan.all
  	update_plan_locations(plans)
  end

  #
  # Update plan locations for the given set of Plan's.
  #
  def update_plan_locations(plans)
  	geo_factory = RGeo::Cartesian.factory
  	wkt_parser = RGeo::WKRep::WKTParser.new(geo_factory)

  	counties_features = get_location_features(wkt_parser, Location::COUNTY)
  	transit_zones_features = get_location_features(wkt_parser, Location::NYCT_ZONE)

    ActiveRecord::Base.uncached do
      plans.find_each batch_size: 100 do |plan|

    	  point_from = geo_factory.point(plan.from_lng, plan.from_lat)
    	  point_to = geo_factory.point(plan.to_lng, plan.to_lat)

    	  # Remove any existing PlanLocation's for this Plan.
    	  plan.plan_locations.clear

    	  # Create and save a PlanLocation for each Location category.
    	  from_category_id, to_category_id = get_from_to_category_ids(counties_features, point_from, point_to)
    	  save_plan_location_for_category(plan, Location::COUNTY, from_category_id, to_category_id)

    	  from_category_id, to_category_id = get_from_to_category_ids(transit_zones_features, point_from, point_to)
    	  save_plan_location_for_category(plan, Location::NYCT_ZONE, from_category_id, to_category_id)
      end
  	end
  end

  #
  # Get Features for the Locations in the given Location category.
  #
  # @param wkt_parser RGeo Well-Known-Text parser
  # @param category_id Location category id
  # @return Hash of Location id's to RGeo Features
  #
  def get_location_features(wkt_parser, category_id)
    locations_for_category = Location.where(category: category_id)
  	features_for_category = Hash.new

	  locations_for_category.each do |location|
  	 	begin
	  		feature = wkt_parser.parse(location.geojson) 
	  		features_for_category[location.id] = feature
  		rescue => e
  			Rails.logger.error "Error parsing feature for location " + location.name
  			Rails.logger.error e.message
  		end
  	end
  	return features_for_category
  end

  #
  # Get the matching Location category id's for the given origin and destination.
  # For example, if the Location category is COUNTY, returns the id of the county that intersects with the origin point
  # and the id of the county that intersects with the destination point.
  # If there is no matching Location, zero is returned for the id.
  #
  # @features_for_category Hash of Location id's to RGeo Features for a given Location category.
  # @point_from The origin point from the plan.
  # @point_to The destination point from the plan.
  # @return Object in format [ from_category_id, to_category_id ]
  #
  def get_from_to_category_ids(features_for_category, point_from, point_to)
	  from_category_id = 0
	  to_category_id = 0
	  features_for_category.each do |location_id, feature|
	  	begin
		  	if point_from.intersects?(feature)
		  		from_category_id = location_id
		  	end
	  	rescue => e
  			Rails.logger.error "Error intersecting point from " + point_from + " with feature for location " + location_id
  			Rails.logger.error e.message
	  	end
	  	begin
		  	if point_to.intersects?(feature)
		  		to_category_id = location_id
		  	end
	  	rescue => e
  			Rails.logger.error "Error intersecting point to " + point_to + " with feature for location " + location_id
  			Rails.logger.error e.message
	  	end

	  	# If both the origin and destination match a location, stop searching.
		if from_category_id > 0 && to_category_id > 0 then
			break
		end
	  end
	  return from_category_id, to_category_id
  end

  #
  # Create and save plan location for the given plan and Location category.
  # The plan location will be added to the existing plan_locations collection.
  #
  # @param plan The plan to create plan locations for.
  # @param category_id Location category id
  # @param from_category_id Location id for the origin point in the category.
  # @param to_category_id Location id for the destination point in the category.
  #
  def save_plan_location_for_category(plan, category_id, from_category_id, to_category_id)
  	begin
	  	if !plan.request_time.nil?
			plan_location = PlanLocation.new
			plan_location.category_id = category_id
			plan_location.from_category_id = from_category_id
			plan_location.to_category_id = to_category_id
			plan_location.plan_request_time = plan.request_time
			plan.plan_locations << plan_location
	  	end
	rescue => e
	  	Rails.logger.error "Error saving plan location for plan " + plan.id
  		Rails.logger.error e.message
	end
  end
end