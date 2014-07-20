Rails.application.routes.draw do
  get 'messages/received'
  get 'messages/sent'
  get 'messages/archived'

	devise_for :users,
						 controllers: {
								 sessions: "users/sessions",
								 registrations: "users/registrations",
								 omniauth_callbacks: "users/omniauth_callbacks"
						 }
	root :to => "dashboard#index"

	get "/fill_phone", to: "phone_number#fill_phone"
	get "/verify_phone_number", to: "phone_number#verify_phone_number"
	get "/confirm_phone", to: "phone_number#confirm_phone"
	get "/confirmation_phone", to: "phone_number#confirmation_phone"
	get "/complete_registration_proccess", to: "users#complete_registration_proccess"
	get "/send_verify_email", to: "users#send_verify_email"
	get "/verified_the_email", to: "users#verified_the_email"
	get "/profile/preferences", to: "preferences#edit"
	get "/profile/notifications", to: "notifications#index"
	get "/profile/social_sharing", to: "users#social_sharing"
	post "/profile/disconnect_facebook", to: "users#disconnect_facebook"
	
	get "/offer-seats/1", to: "rides#offer_seat_1"
	get "/:id/offer-seats/2", to: "rides#offer_seat_2"
	resources :users, only: [] do
		member do
			get :public_profile
		end
	end

	resources :profile, only: [] do
		collection do
			get :general
			get :photo
			get :verifications
			get :address
			patch :update_general_info
			patch :update_address
		end
		member do
			patch :upload_photo
		end
	end
	resources :unsubscribes, only: [] do
		collection do
			get 'account'
			delete 'delete_account'
		end
	end
	resources :cars, only: [:index, :new, :create, :edit, :update, :destroy] do
		member do
			patch :upload_image
		end
	end
	resources :car_makers, only: [] do
		resources :car_models, only: [:index]
	end
	resources :preferences, only: [:update]
	resources :notifications, only: [] do
		collection do
			patch :update_user_notifications
			patch :update_fackbook_notifications
		end
	end
	resources :rides, only: [:index, :destroy, :edit, :update, :show] do
		resources :locations, only: [:destroy]
		collection do
			post :create_offer_1
			post :rides_info
		end
		member do
			patch :create_offer_2
			get :publication
			patch :set_car
			get :contact_to_the_driver
		end
	end

	resources :message_threads, only: [:show, :destroy] do
		resources :messages, only: [:create]
		member do
			post :set_archive
		end
	end

end
