class StaticController < AdminController
  def index
  end

  def show
    render template: "static/route_viz/index"
  end
end