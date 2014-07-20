class Route < ActiveRecord::Base
	belongs_to :ride
	belongs_to :source, class_name: "Location"
	belongs_to :destination, class_name: "Location"
end
          