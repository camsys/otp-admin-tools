module Admin
  class AdminController < ApplicationController
    
    before_action :authenticate_user!
    before_action :confirm_admin

    def confirm_admin
    
      #Check to see if we are logged in
      if current_user.nil?
        redirect_to new_user_session_path 
        return 
      end

    end
  end
end