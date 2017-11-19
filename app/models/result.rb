class Result < ApplicationRecord

  include ComparisonTools

  belongs_to :trip
  belongs_to :test, dependent: :delete 

  serialize :otp_response
  serialize :atis_response

end
