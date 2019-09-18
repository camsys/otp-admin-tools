module AdminHelpers
  
  def get_admin_pages
    urls = Rails.application.routes.url_helpers
    
    @admin_pages = [
      { label: "StationViz",       url: urls.stations_stations_path,  show: true},
      { label: "RouteViz", url: urls.static_route_viz_path, show: true},
      { label: "TripCompare",       url: urls.trip_compare_groups_path,      show: true},
      { label: "OTP Reports", url: urls.admin_reports_path, show: true},
      { label: "Users",        url: urls.admin_users_path,            show: true}
    ].select {|page| page[:show] }
    .sort_by { |page| page[:label] }
  end
  
end