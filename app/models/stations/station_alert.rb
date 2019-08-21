class Stations::StationAlert
  attr_accessor :alert_header_text, :alert_description, :alert_url

  def initialize(alertHeaderText, alertDescription, alertUrl)
    @alert_header_text = alertHeaderText
    @alert_description = alertDescription
    @alert_url = alertUrl
  end
end