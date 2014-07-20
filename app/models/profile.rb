class Profile < ActiveRecord::Base
	require 'file_size_validator'
	belongs_to :user
	belongs_to :country

	attr_accessor :check_photo
	mount_uploader :photo, ProfilePhotoUploader

	validates :photo, :file_size =>
			{
					:maximum => 2.0.megabytes.to_i
			}, :if => "check_photo.present?"

	def get_displayed_as
		self.displayed_as == "1" ? self.user.display_first_last_name : self.user.display_first_name
	end

	def picture(version="default")
		if self.photo.present?
			if version == "profile" || version == "driver"
				self.photo_url(:profile_thumb)
			elsif version == "inbox" 
				self.photo_url(:inbox_thumb)
			elsif version == "public_profile"
				self.photo_url(:public_profile)
			elsif version == "chat"
				self.photo_url(:chat)			
			elsif version == "default"
				self.photo_url
			else
				self.photo_url
			end

		else
			if version == "driver"
				'user/icon-man-driver-108.png'
			elsif version == "public_profile"
				'user/icon-man-144.png'
			elsif version == "inbox"
				'user/icon-man-54.png'
			elsif version == "chat"
				'user/icon-man-72.png'	
			else
				'user/icon-man-108.png'
			end
		end
	end

end
