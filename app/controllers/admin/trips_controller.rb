module Admin
  class TripsController < Admin::AdminController

    def create
      @trip = Trip.create(trip_params)
      @trip.group.geocode_trips
      redirect_to edit_admin_group_path(@trip.group) 
    end

    def destroy
      @trip = Trip.find(params[:id])
      @group = @trip.group 
      @trip.destroy
      redirect_to edit_admin_group_path(@group)
    end

    private

    def trip_params
      params.require(:trip).permit(:origin, :origin_lat, :origin_lng, :destination, :destination_lat, :destination_lng, :time, :arrive_by, :atis_mode, :atis_accessible, :group_id)
    end

  end
end