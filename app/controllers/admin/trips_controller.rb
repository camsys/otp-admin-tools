module Admin
  class TripsController < Admin::AdminController

    def destroy
      @trip = Trip.find(params[:id])
      @group = @trip.group 
      @trip.destroy
      redirect_to edit_admin_group_path(@group)
    end

  end
end