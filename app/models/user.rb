class User < ActiveRecord::Base

	has_one :phone_number
	has_one :profile, dependent: :destroy
	has_one :preference, dependent: :destroy
	has_many :notifications, dependent: :destroy
	has_many :rides, dependent: :destroy
	has_one :unsubscribe
	has_many :cars
	has_many :friends
	has_many :message_threads
	has_many :receiving_message_threads, class_name: :MessageThread, foreign_key: "communicator_id"
	# Include default devise modules. Others available are:
	# :confirmable, :lockable, :timeoutable and :omniauthable
	validates :gender, presence: true, on: :create
	validates :first_name, presence: true, on: :create
	validates :last_name, presence: true, on: :create
	validates :birth_year, presence: true, on: :create

	validates_associated :profile, :if => "enable_profile_validation.present?"
	accepts_nested_attributes_for :profile

	validates_associated :phone_number, :if => "enable_phone_number_validation.present?"
	accepts_nested_attributes_for :phone_number

	validates_associated :notifications, :if => "enable_notifications_validation.present?"
	accepts_nested_attributes_for :notifications

	attr_accessor :enable_profile_validation, :enable_phone_number_validation, :enable_notifications_validation, :ride_id
	devise :database_authenticatable, :registerable,
				 :recoverable, :rememberable, :trackable, :validatable,
				 :omniauthable, omniauth_providers: [:facebook]


	after_create :create_supporting_objects

	def create_supporting_objects
		self.create_profile
		self.create_phone_number
		self.create_preference
		DefaultNotification.all.each do |dn|
			self.notifications.create(name: dn.name, text: dn.text, medium: dn.medium)
		end
	end

	def display_first_name
		self.first_name.titleize
	end

	def display_first_last_name
		"#{self.first_name.titleize} #{self.last_name[0].titleize}"
	end

	def age
		"#{Date.today.year - self.birth_year} years old" rescue ""
	end

	def phone_no_with_ext(separator="")
		if self.phone_number.try(:body).present?
			"#{self.phone_number.try(:country).try(:country_code) }#{separator}#{self.phone_number.try(:body)}"
		else
			""
		end
	end

	def allow_ride_offer_sms?
    self.phone_number.body.present? && self.notifications.where(name: "ride_offer").present?
  end

	def self.new_with_session(params, session)
		super.tap do |user|
			if data = session["devise.facebook_data"] && session["devise.facebook_data"]["extra"]["raw_info"]
				user.email = data["email"] if user.email.blank?
			end
		end
	end

	def self.find_for_facebook_oauth(auth)

		user = User.where(auth.slice(:provider, :uid)).first
		return user if user.present?
		user = User.find_by(email: auth.info.email)
		if user.present?
			user.provider = auth.provider
			user.uid = auth.uid
			user.name = auth.info.name
			user.first_name = auth.info.first_name
			user.last_name = auth.info.last_name
			user.gender = auth.extra.raw_info.gender
			user.save(validate: false)
			return user
		end

		user = User.new(
				provider: auth.provider,
				uid: auth.uid,
				email: auth.info.email,
				name: auth.info.name,
				first_name: auth.info.first_name,
				last_name: auth.info.last_name,
				# image: auth.info.image,
				gender: auth.extra.raw_info.gender
		)
		user.save(validate: false)
		return user
	end


	def self.upload_profile_photo_facebook_oauth(auth)
		user = User.find_by(email: auth.info.email)
		pr = user.profile
		pr.photo = open(auth[:info][:image]) || nil
		pr.save
	end

end
