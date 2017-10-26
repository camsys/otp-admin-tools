class Result < ApplicationRecord
  belongs_to :trip
  has_one :test, through: :trip
end
