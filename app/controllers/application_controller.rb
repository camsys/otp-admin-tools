class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :set_application_title

   	def set_application_title  
    	#@application_title = Rails.configuration.application_title
    	@application_title = 'OTP Reports'
    end

end
