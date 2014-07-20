class ProfileController < ApplicationController

	before_filter :load_profile, only: [:general, :photo, :address, :update_address]
	before_filter :load_phone_number, only: [:general]

	def update_general_info
		old_email = current_user.email
		old_phone_no = current_user.phone_no_with_ext

		if current_user.update(general_user_profile_params)
			if current_user.email != old_email
				current_user.update!(email_verified: false)
			end
			if current_user.phone_no_with_ext != old_phone_no
				current_user.phone_number.update!(verified_no: false)
			end
			redirect_to general_profile_index_path, notice: t('.succeed')
		else
			load_profile
			load_phone_number
			render 'general'
		end
	end

	def upload_photo
		@profile = Profile.find(params[:id])
		if @profile.update(profile_photo_params)
			redirect_to photo_profile_index_path, notice: t('.succeed')
		else
			render 'photo'
		end
	end

	def verifications
		@user = current_user
	end

	def update_address
		if @profile.update(profile_address_params)
			redirect_to address_profile_index_path, notice: t('.succeed')
		else
			render 'address'
		end
	end

	private
	def load_profile
		@user = current_user
		@profile = @user.profile
	end

	def load_phone_number
		@phone_number = @user.phone_number
		@selected_country = @phone_number.get_country
	end

	def general_user_profile_params
		params.require(:user).permit(:first_name, :last_name, :email, :birth_year, :enable_profile_validation, :enable_phone_number_validation, profile_attributes: [:id, :displayed_as, :mini_bio], phone_number_attributes: [:id, :country_id, :body, :public_status])
	end

	def profile_photo_params
		params.require(:profile).permit(:photo, :check_photo)
	end

	def profile_address_params
		params.require(:profile).permit(:address_1, :address_2, :postcode, :city, :country)
	end
end
