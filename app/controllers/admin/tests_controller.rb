module Admin
  class TestsController < Admin::AdminController

    def show
      @test = Test.find(params[:id])
    end
  end
end