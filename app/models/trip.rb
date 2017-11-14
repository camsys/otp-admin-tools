class Trip < ApplicationRecord

  belongs_to :group
  has_many   :results

  def params
    {
      origin: {lat: self.origin_lat, lng: self.origin_lng},
      destination: {lat: self.destination_lat, lng: self.destination_lng}, 
      time: self.time,
      arrive_by: self.arrive_by
    }
  end

end
