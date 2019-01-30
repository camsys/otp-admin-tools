class PlanLocation < ApplicationRecord

	  belongs_to :plan
	  has_many :from_locations, class_name: 'Location', foreign_key: :from_category_id
      has_many :to_locations, class_name: 'Location', foreign_key: :to_category_id

end