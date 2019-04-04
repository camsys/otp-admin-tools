class ApplicationController < ActionController::Base
  include AdminHelpers

  protect_from_forgery with: :exception

  before_action :get_admin_pages
  before_action :set_application_title

   	def set_application_title  
    	#@application_title = Rails.configuration.application_title
    	@application_title = 'OTP Reports'
    end

end
