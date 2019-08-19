module Admin
  class ResultsController < AdminController

    def show
      @result = Result.find(params[:id])
      @otp_summary = @result.otp_summary
      if(@result.compare_type == 'atis')
        @compare_summary = @result.atis_summary
      elsif @result.compare_type == 'otp'
        @compare_summary = @result.otp2_summary
      end
      max_length = [@otp_summary.count, (@compare_summary || []).count].max
      @otp_summary = @otp_summary + Array.new(max_length - @otp_summary.count)
      @compare_summary = (@compare_summary || []) + Array.new(max_length - (@compare_summary || []).count)
      @full_summary = @otp_summary.zip(@compare_summary)
    end

  end
end
