class Type < ApplicationRecord

	has_many :plans

	# Types
	PLAN = 1
	NEARBY = 2
	COLLECTOR = 3
end