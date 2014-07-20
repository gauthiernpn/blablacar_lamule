class UsersController < ApplicationController

	layout "profile", only: [:social_sharing]
	before_filter :load_public_profile, only: [:public_profile]


	def complete_registration_proccess
		if session[:fride_id].present?
			ride_id = session[:fride_id]
			session.delete(:fride_id)
    	redirect_to contact_to_the_driver_ride_path(ride_id)
    else
			flash[:warning] = t('.welcome_message')
			return redirect_to root_path
    end
	end

	def send_verify_email
		begin
			UserMailer.email_verification(current_user).deliver
			redirect_to verifications_profile_index_path, notice: t('.succeed')
		rescue Exception => e
			puts "=== send_verify_email ==="
			puts e
			redirect_to verifications_profile_index_path, danger: e
		end
	end

	def verified_the_email
		if current_user.update(email_verified: true)
			redirect_to verifications_profile_index_path, notice: t('.succeed')
		else
			redirect_to verifications_profile_index_path, danger: t('.failed')
		end
	end

	def disconnect_facebook
		if current_user.update(provider: nil, uid: nil)
			current_user.friends.destroy_all
		end
		redirect_to :back
	end

	def public_profile
		@self_user = current_user && current_user.id == @user.id ? true : false
	end
	
	private
	def load_public_profile
		@user = User.find(params[:id])
		@profile = @user.profile
	end

end