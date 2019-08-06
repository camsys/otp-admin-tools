class Station
  attr_accessor :station_name, :station_id, :nodes, :alerts, :links

  def initialize(stationName, stationId, nodes, alerts, links)
    @station_name = stationName
    @station_id = stationId
    @nodes = nodes
    @alerts = alerts
    @links = links
  end

  def get_all_nodes
    @nodes
    puts @nodes
  end

  def get_all_links
    @links
    puts @links
  end

  def get_all_alerts
    @alerts
    puts @alerts
  end

  def find_node node_id

  end


end