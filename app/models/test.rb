class Test < ApplicationRecord
  belongs_to :group
  has_many :trips, through: :group
  has_many :results, through: :trips  
end
