class StaticController < AdminController
  def index
  end

  def show
    @url = Config.route_viz_url || "http://localhost:8080/otp/routers/default"
    @api_key = Config.route_viz_api_key
    render template: "static/route_viz/index"
  end

end