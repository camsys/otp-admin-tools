class StaticController < AdminController
  def index
  end

  def show
    @url = Config.route_viz_url || "http://localhost:8080/otp/routers/default"
    render template: "static/route_viz/index"
  end

end