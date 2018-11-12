class Admin::ReportsController < Admin::AdminController
  
  DASHBOARDS = ['API Usage', 'Origin Destination']
  GROUPINGS = [:hour, :day, :week, :month, :quarter, :year, :day_of_week, :month_of_year]
  # OTP API calls of interest
  APIS = [:plan, :nearby, :collector]
  
  # Set filters on Dashboards
  before_action :set_dashboard_filters, only: [
    :planned_trips_dashboard,
    :popular_destinations_dashboard
  ]

  before_action :authorize_reports
  
  def index
    @dashboards = DASHBOARDS
    @groupings = GROUPINGS
  end
    
  ### GRAPHICAL DASHBOARDS ###
  
  def dashboard
    params = dashboard_params
    dashboard_name = params[:dashboard_name].parameterize.underscore
    action_name = dashboard_name + "_dashboard"
    filters = params.except(:dashboard_name).to_h # Explicitly convert params to hash to avoid deprecation warning

    redirect_to({controller: 'reports', action: action_name}.merge(filters))
  end
  
  def api_usage_dashboard
    @trips = Trip.from_date(@from_date).to_date(@to_date)
    @trips = @trips.partner_agency_in(@partner_agency) unless @partner_agency.blank?

    # Test data
    trip1 = Trip.new
    trip1.api_key = 'key1'
    trip1.service_name = 'Globant'
    trip1.count_total = 6000
    trip1.count_plan = 4000
    trip1.count_nearby = 1000
    trip1.count_collector = 1000
    trip2 = Trip.new
    trip2.api_key = 'key2'
    trip2.service_name = 'Ayuda'
    trip2.count_total = 1000
    trip2.count_plan = 500
    trip2.count_nearby = 250
    trip2.count_collector = 250
    trip3 = Trip.new
    trip3.api_key = 'key3'
    trip3.service_name = 'OutFront'
    trip3.count_total = 500
    trip3.count_plan = 500
    trip3.count_nearby = 0
    trip3.count_collector = 0
    trip4 = Trip.new
    trip4.api_key = 'key4'
    trip4.service_name = 'MTA'
    trip4.count_total = 2
    trip4.count_plan = 2
    trip4.count_nearby = 0
    trip4.count_collector = 0
    trip5 = Trip.new
    trip5.api_key = 'key5'
    trip5.service_name = 'Monitoring'
    trip5.count_total = 750
    trip5.count_plan = 750
    trip5.count_nearby = 0
    trip5.count_collector = 0
    @trips = [ trip1, trip2, trip3, trip4, trip5 ]

  end
  
  def origin_destination_dashboard
    @trips = Trip.from_date(@from_date).to_date(@to_date)
  end
  
  ### / graphical dashboards  
  
  protected

  # Ensures that current_user has permission to view the reports
  def authorize_reports
    ##
    #authorize! :read, :report
  end
  
  def set_download_table_filters
    
    # TRIP FILTERS
    @trip_time_from_date = parse_date_param(params[:trip_time_from_date])
    @trip_time_to_date = parse_date_param(params[:trip_time_to_date])
    @purposes = parse_id_list(params[:purposes])
    @trip_origin_region = Region.build(recipe: params[:trip_origin_recipe]) 
    @trip_destination_region = Region.build(recipe: params[:trip_destination_recipe])
    @partner_agency = params[:partner_agency].blank? ? nil : PartnerAgency.find(params[:partner_agency])
    
    # USER FILTERS
    @include_guests = parse_bool(params[:include_guests])
    @accommodations = parse_id_list(params[:accommodations])
    @eligibilities = parse_id_list(params[:eligibilities])
    @user_active_from_date = parse_date_param(params[:user_active_from_date])
    @user_active_to_date = parse_date_param(params[:user_active_to_date])
    
    # SERVICE FILTERS
    @service_type = params[:service_type]
    # @accommodations = parse_id_list(params[:accommodations])
    # @eligibilities = parse_id_list(params[:eligibilities])
    # @purposes = parse_id_list(params[:purposes])
    
    # REQUEST FILTERS
    @request_from_date = parse_date_param(params[:request_from_date])
    @request_to_date = parse_date_param(params[:request_to_date])
    
  end
  
  def set_dashboard_filters
    
    # DATE FILTERS
    @from_date = parse_date_param(params[:from_date])
    @to_date = parse_date_param(params[:to_date])
    @grouping = params[:grouping]
    @partner_agency = params[:partner_agency].blank? ? nil : PartnerAgency.find(params[:partner_agency])
    
  end
  
  def download_table_params
    params.require(:download_table).permit(
      :table_name, 
      
      # TRIP FILTERS
      :trip_time_from_date, 
      :trip_time_to_date,
      :trip_origin_recipe,
      :trip_destination_recipe,
      {purposes: []},
      :partner_agency,
      
      # USER FILTERS
      :include_guests,
      {accommodations: []},
      {eligibilities: []},
      :user_active_from_date,
      :user_active_to_date,
      
      # SERVICE FILTERS
      :service_type,
      # {accommodations: []},
      # {eligibilities: []},
      # {purposes: []}
      
      # REQUEST FILTERS
      :request_from_date,
      :request_to_date
      
    )
  end
  
  def dashboard_params
    params.require(:dashboard).permit(
      :dashboard_name, 
      :from_date, 
      :to_date, 
      :grouping,
      :partner_agency
    )
  end
  
  # Parses date param, or returns nil if param is blank
  def parse_date_param(date_param)
    date_param.blank? ? nil : Date.parse(date_param)
  end
  
  # Parses a list of ids, removing blanks and converting to integers
  def parse_id_list(id_list_param)
    id_list_param.to_a.select {|el| !el.blank? }.map(&:to_i)
  end
  
  # Parses a boolean string, either "true", "false", "1", or "0"
  def parse_bool(bool_param)
    bool_param.try(:to_bool) || (bool_param.try(:to_i) == 1)
  end

end
