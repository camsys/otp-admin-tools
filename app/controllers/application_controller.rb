class ApplicationController < ActionController::Base
  include AdminHelpers

  protect_from_forgery with: :exception

  before_action :get_admin_pages

end
