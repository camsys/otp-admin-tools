class StationLink
  attr_accessor :id, :equipment_id, :source, :destination, :type, :pathway_code, :is_active

  # id
  # equipmentId (this might be some internal MTA designation for this entity, e.g. all links which physically are served by the same elevator would have the same device ID)
  # source (node id)
  # destination (node id)
  # type (elevator, escalator, path, eventually others e.g. ramp)
  # pathwayCode ?????
  # isActive (true for most links, false if this link is served by an elevator which is scheduled to have an outage.)


  def initialize(id, equipmentId, source, destination, type, pathwayCode, isActive)
    @id = id
    @equipment_id = equipmentId
    @source = source
    @destination = destination
    @type = type
    @pathway_code = pathwayCode
    @is_active = isActive
  end

  end