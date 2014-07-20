class Country < ActiveRecord::Base
	has_many :phone_numbers
	has_many :profiles
end

