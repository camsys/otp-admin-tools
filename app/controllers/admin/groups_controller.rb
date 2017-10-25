module Admin
  class GroupsController < ApplicationController

    def index
      @groups = Group.all 
      @new_group = Group.new 
    end
  end
end