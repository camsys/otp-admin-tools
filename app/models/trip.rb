class Trip < ApplicationRecord

  belongs_to :group
  has_many :results

end
