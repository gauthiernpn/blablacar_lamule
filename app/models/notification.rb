class Notification < ActiveRecord::Base
	belongs_to :user
	scope :sms_notifications, -> { where(medium: "sms") }
	scope :email_notifications, -> { where(medium: "email") }
	scope :facebook_notifications, -> { where(medium: "facebook") }

end
