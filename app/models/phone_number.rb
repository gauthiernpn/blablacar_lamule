class PhoneNumber < ActiveRecord::Base
	belongs_to :user
	belongs_to :country

	def get_country
		self.country_id.present? ? self.country : Country.find_by(name: GlobalConstants::DEFAULT_COUNTRY)
	end

  def public?
    self.public_status != 1
  end

end
