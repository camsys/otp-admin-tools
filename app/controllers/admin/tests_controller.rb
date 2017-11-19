module Admin
  class TestsController < Admin::AdminController

    def show
      @test = Test.find(params[:id])
    end

    def destroy
      @test = Test.find(params[:id])
      @group = @test.group 
      @test.destroy
      redirect_to edit_admin_group_path(@group)
    end

  end
end