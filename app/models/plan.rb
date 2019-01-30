class Plan < ApplicationRecord

  has_one :plan_location
  has_many :types

end