class Ride < ActiveRecord::Base
	has_many :routes, dependent: :destroy
	has_many :locations, dependent: :destroy
	has_many :message_threads, dependent: :destroy
	belongs_to :car
	belongs_to :user

	has_many :ride_weeks, dependent: :destroy
	validates :departure_date, presence: true
	validates :number_of_seats, :numericality => { only_integer: true }
	validates :number_of_seats, inclusion: { in: 1..7, message: "Number of seats must be less than or equal to 7." }
	validates :return_date, presence: true, :if => "is_round_trip.present?"
	validate :present_tos
	validate :present_car
	validate :blow_departure_date

	attr_accessor :enable_locations_validation, :enable_routes_validation, :accept_tos, :enable_ride_weeks_validation
	validates_associated :locations, :if => "enable_locations_validation.present?"
	accepts_nested_attributes_for :locations, allow_destroy: true

	validates_associated :routes, :if => "enable_routes_validation.present?"
	accepts_nested_attributes_for :routes

	validates_associated :ride_weeks, :if => "enable_ride_weeks_validation.present?"
	accepts_nested_attributes_for :ride_weeks


	def blow_departure_date
		if (departure_date.to_i > return_date.to_i) && is_round_trip.present?
			errors.add(:return_date, "Please set your return date after the departure date.")
		end
	end


  # Note this does not increment the value of views_count for this instance,
  # as it's calling a class method. You'll have to reload this instance
  # to see the new value.
  def increment_views_count
    self.class.increment_counter :views_count, self.id
  	self.reload
  end

	def present_car
		if car_id.present? &&  car_id == 0
			errors.add(:car_id, "Please mention your car for this ride.")
		end
	end

	def present_tos
		if accept_tos.present? && accept_tos == "no"
			errors.add(:accept_tos, "You must certify holding a driving license and valid car insurance to be able to publish your ride offer.")
		end
	end

	def source_location
		self.locations.find_by(ride_type: GlobalConstants::Locations::RIDE_TYPES[:source])
	end

	def destination_location
		self.locations.find_by(ride_type: GlobalConstants::Locations::RIDE_TYPES[:destination])
	end

	def sub_locations
		self.locations.where(ride_type: GlobalConstants::Locations::RIDE_TYPES[:sub_route])
	end

	def set_routes
		if self.routing_required.present?

			self.locations.each do |l|
				l.destroy if l.address.blank?
			end

			self.routes.destroy_all
			locations = self.locations.reorder('sequence ASC')

			if locations.count > 1
				counter_last_val = locations.count - 2
				for i in 0..counter_last_val
					self.routes.create(source_id: locations[i].try(:id), destination_id: locations[i+1].try(:id), price: 1)
				end # end of for loop
				self.update!(routing_required: true)
			end # end of if of location count
		end
	end

	def show_sorce_destination_route
		"#{self.source_location.get_route_name} → #{self.destination_location.get_route_name}"
	end

	def handle_return_date_and_recurring_weeks
		if self.is_round_trip.blank? && self.return_date.present?
			self.update(return_date: nil)
		end
		if self.is_recurring_trip.blank?
			self.ride_weeks.update_all(sat: false, sun: false, mon: false, tue: false, wed: false, thu: false, fri: false)
		end
	end

	def calculate_total_price
		self.routes.map(&:price).sum
	end

	def send_published_confirmation
		if self.user.notifications.where(name: "ride_offer_published").present?
			UserMailer.ride_offer_confirmation(self).deliver
		end
	end

	def send_updated_confirmation
		if self.user.notifications.where(name: "ride_offer_updated").present?
			UserMailer.ride_offer_confirmation(self).deliver
		end
	end

	def send_private_message( sender, receiver, message_body )
		message_threads_id = self.create_message(sender.id, receiver.id, message_body)
		
		if receiver.notifications.where(name: "receive_private_message").present?
			UserMailer.ride_private_message(self, sender, receiver, message_body, message_threads_id[:receiving_message_thread_id]).deliver
		end
		return message_threads_id[:sending_message_thread_id]
	end

	def create_message(sender_id, receiver_id, message_body)
		
		sending_message_thread = self.message_threads.find_or_create_by( user_id: sender_id, communicator_id: receiver_id )
		receiving_message_thread = self.message_threads.find_or_create_by( user_id: receiver_id, communicator_id: sender_id )
		sending_message_thread.update!(unread: true) if sending_message_thread.unread.blank?
		
		if receiving_message_thread.unread.blank? || receiving_message_thread.status == GlobalConstants::MessageThreads::STATUS[:archived]
			receiving_message_thread.update!(unread: true, status: GlobalConstants::MessageThreads::STATUS[:active])
		end
		sending_message_thread.messages.create!(body: message_body, message_type: GlobalConstants::Messages::TYPE[:sent])
		receiving_message_thread.messages.create!(body: message_body, message_type: GlobalConstants::Messages::TYPE[:received])
		return {sending_message_thread_id: sending_message_thread.id, receiving_message_thread_id: receiving_message_thread.id }
	end

	def send_ride_offer_sms( sender, receiver, message_body )
		if receiver.allow_ride_offer_sms?
			client = Twilio::REST::Client.new GlobalConstants::TWILIO_ID, GlobalConstants::TWILIO_TOKEN
			# message = "LaMule: A new passenger #{sender.display_first_last_name} has just sent you a message about your trip #{self.show_sorce_destination_route} at #{self.departure_date.strftime("%A %d %B %Y - %I:%M %p")}. To answer go to LaMule."
			message = "New message on Lamule! \n #{message_body}\n -- #{sender.display_first_last_name}.\n To answer go to Lamule."
			client.account.messages.create(
					body: message,
					to: user.phone_no_with_ext,
					from: GlobalConstants::FROM_NUMBER
			)
		end

	end

end