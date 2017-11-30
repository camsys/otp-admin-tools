module Admin
  class ResultsController < Admin::AdminController

    def show
      @result = Result.find(params[:id])
      @otp_summary = @result.otp_summary
      @atis_summary = @result.atis_summary

      max_length = [@otp_summary.count, @atis_summary.count].max
      @otp_summary = @otp_summary + Array.new(max_length - @otp_summary.count)
      @atis_summary = @atis_summary + Array.new(max_length - @atis_summary.count)

      @full_summary = @otp_summary.zip(@atis_summary)

    end

  end
end
