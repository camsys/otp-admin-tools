class Stations::StationNode
  attr_accessor :id, :label, :lat, :lon, :type, :way_id, :is_accessible
#
#   id
#   lat
#   lon (lat/lon might be fake for mezzanines and elevator entrances)
#   type (ENTRANCE, STOP, MEZANINE,.. other?)
#   wayId (if this is an entrance, include the OSM way ID that it is connected to)
#   isAccessible (false if this node is not accessible from the street for people in wheelchairs at the date and time specified, otherwise true)


  def initialize(id, label, lat, lon, type, osmWayId, accessible)
    @id = id
    @label = label
    @lat = lat
    @lon = lon
    @type = type
    @way_id = osmWayId
    @is_accessible = accessible
  end

end