module Admin
  class GroupsController < ApplicationController

    def index
      @groups = Group.all 
      @new_group = Group.new 
    end

    def create
      @group = Group.create(group_params)
      redirect_to admin_groups_path
    end

    private

    def group_params
      params.require(:group).permit(:name, :comment)
    end
  end
end