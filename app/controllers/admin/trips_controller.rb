module Admin
  class TripsController < AdminController

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

    def edit
      @trip = Trip.find(params[:id])
    end

    def update
      @trip = Trip.find(params[:id])
      @trip.update_attributes(trip_params)
      @trip.group.geocode_trips
      redirect_to edit_admin_group_path(@trip.group) 
    end

    private

    def trip_params
      params.require(:trip).permit(:origin, :origin_lat, :origin_lng, :destination, :destination_lat, :destination_lng, 
        :time, :arrive_by, :atis_mode, :atis_accessible, :group_id, 
        :expected_route_pattern, :max_walk_seconds, :min_walk_seconds, :max_total_seconds, :min_total_seconds, :otp_mode)
    end

  end
end