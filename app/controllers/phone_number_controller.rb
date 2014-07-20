class PhoneNumberController < ApplicationController

	before_action :load_phone_number, only: [:fill_phone, :verify_phone_number, :confirm_phone, :confirmation_phone]

	def fill_phone
		@selected_country = @phone_number.get_country
	end

	def verify_phone_number
		client = Twilio::REST::Client.new GlobalConstants::TWILIO_ID, GlobalConstants::TWILIO_TOKEN
		phone = "#{params[:country_code]}#{params[:phone_number]}".gsub(/[^+0-9]/, "")
		begin
			code = rand.to_s[3..6]
			message = t('.send_message', code: code)
			a = client.account.messages.create(
					body: message,
					to: phone,
					from: GlobalConstants::FROM_NUMBER
			)
			@phone_number.update!(body: params[:phone_number], verification_code: code, country_id: params[:country_id])
			return render json: true
		rescue Exception => e
			puts "=== verify_phone_number ==="
			puts e
			return render json: false;
		end

	end

	def confirm_phone
		if @phone_number.verification_code == params[:code].to_i
			begin
				@phone_number.update!(verified_no: true, verification_code: nil)
				return render json: true
			rescue Exception => e
				puts "=== confirm_phone ==="
				puts e
				return render json: false;
			end
			return render json: true
		else
			return render json: false
		end
	end

	private
	def load_phone_number
		@phone_number = current_user.phone_number
	end

end
