class Location < ApplicationRecord

	has_many :from_locations, class_name: 'PlanLocation', foreign_key: :from_category_id
    has_many :to_locations, class_name: 'PlanLocation', foreign_key: :to_category_id

	# Location categories
	COUNTY = 1
	NYCT_ZONE = 2
	LIRR_AREA = 3
	MNR_AREA = 4
end