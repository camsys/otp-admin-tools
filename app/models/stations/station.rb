class Stations::Station
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

  def find_entrance_nodes
    entrance_nodes = []
    @nodes.each do |node|

      if node.type == 'ENTRANCE'
        entrance_nodes << node
      end

    end

    entrance_nodes
  end

  def find_stop_nodes
    stop_nodes = []
    @nodes.each do |node|

      if node.type == 'STOP'
        stop_nodes << node
      end

    end

    stop_nodes
  end

  def find_other_nodes
    other_nodes = []
    @nodes.each do |node|

    if (node.type != 'STOP' && node.type != 'ENTRANCE')
      other_nodes << node
    end

  end

    other_nodes
  end

  def as_json(options={})
    super(options).merge!({
            station_name: @station_name,
            station_id: @station_id,
            nodes: @nodes,
            alerts: @alerts,
            links: @links,
            find_entrance_nodes: self.find_entrance_nodes,
            find_stop_nodes: self.find_stop_nodes,
            find_other_nodes: self.find_other_nodes
        })
  end

end