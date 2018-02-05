module Admin
  class TestsController < Admin::AdminController

    def show
      @test = Test.find(params[:id])
      @test_results =  @test.results.page(params[:page]).per(50)
    end

    def destroy
      @test = Test.find(params[:id])
      @group = @test.group 
      @test.destroy
      redirect_to edit_admin_group_path(@group)
    end

  end
end