class OtpStop
  attr_accessor :id, :name, :lat, :lon, :cluster

  def initialize(id, name, lat, lon, cluster)
    self.id = id
    self.name = name
    self.lat = lat
    self.lon = lon
    self.cluster = cluster
  end
end