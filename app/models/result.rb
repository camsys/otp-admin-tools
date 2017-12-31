class Result < ApplicationRecord

  include ComparisonTools

  belongs_to :trip
  belongs_to :test, dependent: :delete 

  serialize :otp_response
  serialize :atis_response

  def parsed_atis_response
    if self.atis_response.nil?
      return nil
    end
    Hash.from_xml(self.atis_response)["Envelope"]["Body"]["PlantripResponse"]
  end

end
