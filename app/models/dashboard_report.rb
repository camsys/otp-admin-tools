# Service object for rendering dashboard reports based on config variables
# To define a new report type, add its name to the REPORT_TYPES array, (e.g. :report_name)
# and define a private method called "report_name_html" that returns HTML based on the @params hash
class DashboardReport
  
  # Expose a class variable for containing recipes for prebuilt reports.
  cattr_accessor :prebuilt_reports
  # Reports are stored in a hash, with the key being the name of the report,
  # and the value being an array of the params that will be passed to 
  # DashboardReport.new() to build that report.
  self.prebuilt_reports ||= {}
  
  include Chartkick::Helper
  
  # List of valid report types. Will not attempt to build reports with names not in this list.
  REPORT_TYPES = [
    :planned_trips,
    :popular_destinations,
    :origin_destination_counts_daily,
    :origin_destination_counts_weekly,
    :origin_destination_counts_monthly,
    :origin_destination_dist_day_of_week,
    :origin_destination_dist_hour_weekday,
    :origin_destination_dist_hour_weekend,
    :origin_destination_dist_planned,
  ]
  
  # Default formatting options to pass to chartkick calls as the :library option
  DEFAULT_CHART_OPTIONS = {
    chartArea: { width: '90%', height: '75%' },
    vAxis: { format: '#' }
  }

  COUNT_CHART_OPTIONS = {
    chartArea: { width: '90%', height: '25%' },
    vAxis: { format: '#' }
  }
  
  def initialize(report_type=nil, params={})
    @report_type = report_type.try(:to_sym)
    @params = params
  end

  # Builds google chart html, based on report type
  def html
    REPORT_TYPES.include?(@report_type) ? self.send("#{@report_type}_html") : nil
  end
  
  # Returns true/false if the report can actually be rendered
  def valid?
    html.present?
  end
  
  # Builds a DashboardReport object based on a predefined recipe
  def self.prebuilt(report_name)
    report_name = report_name.to_s.parameterize.to_sym
    if(self.prebuilt_reports.include?(report_name))
      return self.new(*self.prebuilt_reports[report_name])
    else
      return nil
    end
  end
  
  
  private
  
  ### REPORT BUILDER METHODS ###

  def origin_destination_counts_daily_html
    report_units = @params[:report_units]
    data = report_units.group_by_day(:request_time).count
    return line_chart(data,
      id: "counts_daily",
      ytitle: "Daily",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end

  def origin_destination_counts_weekly_html
    report_units = @params[:report_units]
    data = report_units.group_by_week(:request_time).count
    return line_chart(data,
      id: "counts_weekly",
      ytitle: "Weekly",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end

  def origin_destination_counts_monthly_html
    report_units = @params[:report_units]
    data = report_units.group_by_month(:request_time).count
    return line_chart(data,
      id: "counts_monthly",
      ytitle: "Monthly",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end
  
  def origin_destination_dist_day_of_week_html
    report_units = @params[:report_units]
    data = report_units.group_by_day_of_week(:request_time, format: "%a", week_start: :mon).count
    return column_chart(data,
      id: "dist_day_of_week",
      ytitle: "Day of Week",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end

  def origin_destination_dist_hour_weekday_html
    report_units = @params[:report_units]
    data = report_units.where("extract(dow from request_time) in (1, 2, 3, 4, 5)").group_by_hour_of_day(:request_time, format: "%-l %p").count
    return column_chart(data,
      id: "dist_hour_weekday",
      ytitle: "By Hour (Weekdays)",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end

  def origin_destination_dist_hour_weekend_html
    report_units = @params[:report_units]
    data = report_units.where("extract(dow from request_time) in (0, 6)").group_by_hour_of_day(:request_time, format: "%-l %p").count
    return column_chart(data,
      id: "dist_hour_weekend",
      ytitle: "By Hour (Weekend/Holiday)",
      download: true,
      thousands: ",",
      library: COUNT_CHART_OPTIONS)
  end

  def origin_destination_dist_planned_html
    report_units = @params[:report_units]
    now = DateTime.now
    nowEnd = now + 1.hours
    today = Date.today
    dataNow = report_units.where("request_time >= ? AND request_time < ?", now, nowEnd).count
    dataLaterToday = report_units.where(:request_time => nowEnd..(now.end_of_day)).count
    dataFuture = report_units.where(:request_time => (today + 1)..(today + 3)).group_by_day(:request_time).count
    data = {'Now' => dataNow, 
      'Later Today' => dataLaterToday, 
      'Tomorrow' => dataFuture[today + 1], 
      '+2' => dataFuture[today + 2], 
      '+3' => dataFuture[today + 3]
    }
    return column_chart(data,
      id: "dist_planned",
      ytitle: "Day Planned",
      download: true,
      library: COUNT_CHART_OPTIONS)
  end

  # Builds the html for a planned trips report, based on the passed params
  def planned_trips_html
    trips = @params[:trips] || Trip.all
    grouping = @params[:grouping] || :month
    #grouped_trips = trips.send("group_by_#{grouping}", :trip_time, date_grouping_options(grouping)).count
    return column_chart(grouped_trips,
      id: "trips-planned-by-#{grouping}",
      title: @params[:title] || "Trips Planned by #{grouping.to_s.titleize}",
      library: DEFAULT_CHART_OPTIONS)
  end
  
  # Builds the html for a popular destinations report, based on the passed params
  def popular_destinations_html
    trips = @params[:trips] || Trip.all
    limit = @params[:limit] || 10
    destinations = Waypoint.where(id: trips.pluck(:destination_id))
                           .where.not(lat: nil, lng: nil)
                           .group(:lat, :lng, :name).count
                           .sort_by {|k,v| v }.reverse.take(limit).to_h
                           .map { |k,v| k.last.present? ? [k.last,v] : ["#{k[0]}, #{k[1]}",v] }.to_h    
    return pie_chart(destinations,
      id: "popular-destinations",
      title: "Popular Trip Destinations",
      library: DEFAULT_CHART_OPTIONS)
  end
  
  ### /report builder methods
  
  
  # Formats date groupings for a column chart, based on type of grouping
  def date_grouping_options(grouping)
    {
      format: {
          "day" => "%m/%d",
          "day_of_week" => "%a",
          "month_of_year" => "%b"
      }[grouping.to_s]
    }
  end
  
end
