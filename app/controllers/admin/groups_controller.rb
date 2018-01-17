module Admin
  class GroupsController < Admin::AdminController

    def index
      @groups = Group.all 
      @new_group = Group.new 
    end

    def create
      @group = Group.create(group_params)
      redirect_to admin_groups_path
    end

    def edit
      @group = Group.find(params[:id]) 
      @new_trip = Trip.new
      @new_trip.time = Time.now 
    end


    def destroy
      @group = Group.find(params[:id])
      @group.destroy
      redirect_to admin_groups_path
    end

    def run_test
      @group = Group.find(params[:id])
      @group.update_attributes(group_params)
      RunTestsJob.perform_later(@group.id)
      redirect_to edit_admin_group_path(@group)
    end

    def geocode
      @group = Group.find(params[:id])
      @group.geocode_trips
      redirect_to edit_admin_group_path(@group)
    end

    def update
      info_msgs = []
      error_msgs = []

      @group = Group.find(params[:id])

      trips_file = params[:group][:file] if params[:group]
      if !trips_file.nil?
        response, message =  @group.update_trips trips_file
        if response
          info_msgs << message
        else
          error_msgs << message
        end
      else
        error_msgs << "Upload a csv file containing the new Trips."
      end

      if error_msgs.size > 0
        flash[:danger] = error_msgs.to_sentence
      elsif info_msgs.size > 0
        flash[:success] = info_msgs.to_sentence
      end

      respond_to do |format|
        format.js
        format.html {redirect_to edit_admin_group_path(@group)}
      end
    end

    private

    def group_params
      params.require(:group).permit(:name, :comment, 
        :otp_walk_speed, :otp_max_walk_distance, :otp_walk_reluctance, :otp_transfer_penalty,
        :atis_minimize, :atis_walk_dist, :atis_walk_speed, :atis_walk_increase, :otp_accessible, :atis_accessible)
    end
  end
end
