class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController

	def facebook
		auth = request.env["omniauth.auth"]
		@user = User.find_for_facebook_oauth(auth)
		@graph = Koala::Facebook::API.new(auth.credentials.token)
		profile = @graph.get_object("me")
		friends = @graph.get_connections("me", "friends")
		puts friends
		add_friends(friends, @user)
		if session[:ride_id].present?
			set_ride_user
		elsif session[:fride_id].present?
			set_find_ride_user
		elsif @user.persisted?
			sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
			set_flash_message(:notice, :success, :kind => "Facebook") if is_navigational_format?
		else
			session["devise.facebook_data"] = request.env["omniauth.auth"]
			redirect_to new_user_registration_url
		end
	end


	private

	def add_friends(friends, user)
		begin
			friends.each do |friend|
				Friend.create(name: friend["name"], friend_id: friend["id"], user_id: user.id) unless @user.friends.find_by_friend_id(friend["id"])
			end
		rescue Exception => e
			puts "add friends"
			puts e
		end
	end
end