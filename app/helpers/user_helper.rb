module UserHelper

	def phone_countries_options(countries, selected_country)
		countries.each do |country|
			content_tag "option", country.name, value: country.id, data: { code: country.country_code, format: country.country_format }
		end.join("\n")
	end

end

