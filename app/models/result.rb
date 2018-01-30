class Result < ApplicationRecord

  include ComparisonTools
  include OtpTools

  belongs_to :trip
  belongs_to :test, dependent: :delete 

  serialize :otp_response
  serialize :compare_response

  def parsed_atis_response
    if self.compare_type != 'atis' || self.compare_response.nil?
      return nil
    end
    Hash.from_xml(self.compare_response)["Envelope"]["Body"]["PlantripResponse"]
  end


  def comparison_service_name
    if self.compare_type == 'atis'
      return "ATIS"
    else
      return "OTP2"
    end
  end

end
