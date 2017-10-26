class RenameResultsToOtpResults < ActiveRecord::Migration[5.0]
  def change
    rename_column :results, :request, :otp_request
    rename_column :results, :response, :otp_response
  end
end
