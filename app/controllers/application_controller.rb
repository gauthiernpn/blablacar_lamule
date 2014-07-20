class ApplicationController < ActionController::Base
	# Prevent CSRF attacks by raising an exception.
	# For APIs, you may want to use :null_session instead.
	protect_from_forgery with: :exception
	before_action :update_sanitized_params, if: :devise_controller?

	protected
	def set_ride_user
		ride = Ride.find(session[:ride_id]) rescue nil
		if ride.present?
			ride.update!(user_id: @user.id)
			ride.send_published_confirmation
			flash[:notice] = t('rides.published', ride_id: ride.id)
			session.delete(:ride_id)
			scope = Devise::Mapping.find_scope!(@user)
			sign_in(scope, @user)
			redirect_to publication_ride_path(ride.id)
		else
			session.delete(:ride_id)
			redirect_to root_path
		end
	end

	def set_find_ride_user
		ride = Ride.find(session[:fride_id]) rescue nil
		if ride.present?
			scope = Devise::Mapping.find_scope!(@user)
			sign_in(scope, @user)
			if current_user.phone_number.body.present?
				session.delete(:fride_id)
				redirect_to contact_to_the_driver_ride_path(ride.id)
			else
				redirect_to fill_phone_path
			end
		else
			session.delete(:fride_id)
			redirect_to root_path
		end
	end

	# def locations_distance (lat1,lon1,lat2,lon2) {
	#   R = 6371; # km (change this constant to get miles)
	#   dLat = (lat2-lat1) * Math.PI / 180;
	#   dLon = (lon2-lon1) * Math.PI / 180;
	#   a = Math.sin(dLat/2) * Math.sin(dLat/2) +
	#     Math.cos(lat1 * Math.PI / 180 ) * Math.cos(lat2 * Math.PI / 180 ) *
	#     Math.sin(dLon/2) * Math.sin(dLon/2);
	#   var c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a));
	#   var d = R * c;
	#   if d > 1
	#    return "#{ Math.round(d) }km";
	#   elsif d <= 1
	#    return "#{ Math.round(d*1000) }m";
	#   end
	#   return d;
	# end

	private
	def update_sanitized_params
		devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:gender, :first_name, :last_name, :email, :password, :password_confirmation, :birth_year, :receive_updates, :ride_id) }
	end

end
