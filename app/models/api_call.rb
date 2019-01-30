class ApiCall < ApplicationRecord

	  has_many :types
	  has_many :api_keys

end