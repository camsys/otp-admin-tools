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
    private
    
    # Presents a flash message of errors attached to the given object
    def present_error_messages(record)
      error_msgs = (record.errors.try(:full_messages) || 
                    record.errors || 
                    []).to_sentence
      flash[:danger] = error_msgs unless error_msgs.empty?
    end

  end
end