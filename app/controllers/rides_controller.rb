class RidesController < ApplicationController
	before_action :set_ride, only: [:show, :update, :contact_to_the_driver]
	before_action :set_user_ride_or_default_ride, only: [:edit, :offer_seat_2, :destroy, :set_car]
	# GET /rides
	# GET /rides.json
	def index
		@rides = current_user.rides
	end

	# GET /rides/1
	# GET /rides/1.json
	def show
		@ride = Ride.find params[:id]
    @user = @ride.user
    @self_user = current_user && current_user.id == @user.id ? true : false

    @ride.increment_views_count
	end

	def set_car
		if @ride.update(car_id: params[:ride][:car_id])
			redirect_to ride_path(@ride.id)
		else
			redirect_to ride_path(@ride.id)
		end
	end

	def offer_seat_1
		@ride = Ride.new
		build_init_locations
		build_init_recuring_weeks
	end

	def create_offer_1

		if user_signed_in?
			@ride = current_user.rides.build(offer_1_ride_params)
		else
			@ride = Ride.new(offer_1_ride_params)
		end

		respond_to do |format|

			if @ride.save
				@ride.set_routes
				@ride.handle_return_date_and_recurring_weeks
				format.html { redirect_to "/#{@ride.id}/offer-seats/2" }
				format.json { render :show, status: :created, location: @ride }
			else

				# build_init_locations
				format.html { render 'offer_seat_1', danger: "Please correct the error(s) listed below" }
				format.json { render json: @ride.errors, status: :unprocessable_entity }
			end
		end
	end

	def offer_seat_2
		@routes = @ride.routes
		@locations = @ride.locations.reorder('sequence ASC')
	end

	def create_offer_2
		respond_to do |format|

			if user_signed_in?
				@ride = current_user.rides.find(params[:id])
				if @ride.update(offer_2_ride_params)
					total_price = @ride.calculate_total_price
					if @ride.full_completed < 2
						@ride.update!(created_at: Time.now, total_price: total_price)
						@ride.send_published_confirmation
						flash[:notice] = t('rides.published', ride_id: @ride.id)
						format.html { redirect_to publication_ride_path(@ride.id) }
					else
						@ride.update!(total_price: total_price)
						@ride.send_updated_confirmation
						flash[:notice] = t('rides.updated', ride_id: @ride.id)
						format.html { redirect_to publication_ride_path(@ride.id) }
					end
					format.json { render :show, status: :created, location: @ride }
				else
					@routes = @ride.routes
					@locations = @ride.locations
					format.html { render 'offer_seat_2', danger: "Please correct the error(s) listed below" }
					format.json { render json: @ride.errors, status: :unprocessable_entity }
				end
			else
				@ride = Ride.find(params[:id])
				if @ride.update(offer_2_ride_params)

					format.html { redirect_to new_user_registration_path({ rid: @ride.id }) }
					format.json { render :show, status: :created, location: @ride }
				else
					@routes = @ride.routes
					@locations = @ride.locations
					format.html { render 'offer_seat_2', danger: "Please correct the error(s) listed below" }
					format.json { render json: @ride.errors, status: :unprocessable_entity }
				end
			end
		end
	end

	# PATCH/PUT /rides/1
	# PATCH/PUT /rides/1.json
	def update
		respond_to do |format|
			if @ride.update(offer_1_ride_params)
				@ride.set_routes
				@ride.handle_return_date_and_recurring_weeks
				format.html { redirect_to "/#{@ride.id}/offer-seats/2" }
				format.json { render :show, status: :created, location: @ride }
			else
				format.html { render :edit }
				format.json { render json: @ride.errors, status: :unprocessable_entity }
			end
		end
	end

	# DELETE /rides/1
	# DELETE /rides/1.json
	def destroy
		@ride.destroy
		respond_to do |format|
			format.html { redirect_to rides_url, notice: 'Ride was successfully destroyed.' }
			format.json { head :no_content }
		end
	end

	

	def rides_info
		if params[:ride_source].present?
			@rides_id = Location.where(ride_type: GlobalConstants::Locations::RIDE_TYPES[:source]).near(params[:ride_source], (15 * Geocoder::Calculations::KM_IN_MI)).map(&:ride_id)
		end
		if params[:ride_destination].present?
			@rides_id.concat(Location.where(ride_type: GlobalConstants::Locations::RIDE_TYPES[:destination]).near(params[:ride_destination], (15 * Geocoder::Calculations::KM_IN_MI)).map(&:ride_id))
		end
		if @rides_id.blank?
			redirect_to root_path
		end

		@rides = Ride.where("rides.id IN (?) AND rides.user_id IS NOT NULL AND rides.departure_date > ? AND rides.full_completed > ?", @rides_id.uniq, Time.now, 0).order(params[:order_by])
		@pro_pho_check = false
		if params[:profile_photo] == "only"
			@rides = Ride.joins(user: :profile).where("profiles.photo IS NOT NULL")
			@pro_pho_check = true
		end

		if params[:start_time].present? && params[:last_time].present?
			# start_time = "#{params[:start_time]}00"
			# last_time = "#{params[:last_time]}00"
			# @rides = @rides.where("Extract(HOUR_MINUTE from rides.departure_date) between ? and ?", start_time, last_time)

			start_time = "#{params[:start_time]}".to_i
			last_time = "#{params[:last_time]}".to_i
			@rides = @rides.where("Extract(HOUR from rides.departure_date) between ? and ?", start_time, last_time)
			
		end

		if params[:departure_date].present?
			dep_date = params[:departure_date].to_date
			@rides = @rides.where("rides.departure_date >= ? AND rides.departure_date <= ?", dep_date, "#{dep_date} 23:59:59.996")
		end
		@rides_with_photo = Profile.where("profiles.user_id IN (?) AND profiles.photo IS NOT NULL", @rides.map(&:user_id)).count
	end

	def contact_to_the_driver
		if params[:private_msg].present?
			if !user_signed_in?
				redirect_to new_user_registration_path({frid: @ride.id})
			else
				@user = @ride.user
				@ride.send_ride_offer_sms(current_user, @user, params[:private_msg])
				sending_message_thread_id = @ride.send_private_message(current_user, @user, params[:private_msg])
				redirect_to message_thread_path(sending_message_thread_id)
			end
		else
			redirect_to ride_path(@ride.id)
		end	
	end

	private
	# Use callbacks to share common setup or constraints between actions.
	def set_ride
		@ride = Ride.find(params[:id])
	end

	def set_user_ride_or_default_ride
		@ride = Ride.find(params[:id])
		if  @ride.user_id.present? && @ride.user_id !=  current_user.id
			redirect_to root_path, danger: "your are not authorize to access this page."
		end
	end
	# Never trust parameters from the scary internet, only allow the white list through.
	def offer_1_ride_params
		# params[:ride][:departure_time] = params[:ride][:departure_date].to_time
		params.require(:ride).permit(
				:departure_date,
				:return_date,
				:is_recurring_trip,
				:is_round_trip,
				:number_of_seats,
				:enable_locations_validation,
				locations_attributes: [:id, :address, :longitude, :latitude, :sequence, :ride_type],
				ride_weeks_attributes: [:id, :mon, :tue, :wed, :thu, :fri, :sat, :sun, :date_type]
		)
	end

	def offer_2_ride_params
		if params[:ride][:car_id] && params[:ride][:car_id].nil?
			params[:ride][:car_id] = 0
		end

		params.require(:ride).permit(:general_details, :specific_details, :your_car, :number_of_seats, :max_luggage_size, :is_details_same, :leaving_delay, :detour_preferences, :accept_tos, :car_id, :full_completed, :total_distance, :total_time, :enable_routes_validation, routes_attributes: [:id, :price])
	end

	def build_init_locations
		@source = @ride.locations.build(ride_type: GlobalConstants::Locations::RIDE_TYPES[:source])
		@sub_routes = @ride.locations.build(ride_type: GlobalConstants::Locations::RIDE_TYPES[:sub_route])
		@destination = @ride.locations.build(ride_type: GlobalConstants::Locations::RIDE_TYPES[:destination])
	end

	def build_init_recuring_weeks
		@outbound_week = @ride.ride_weeks.build(date_type: GlobalConstants::Ride_weeks::DATE_TYPES[:outbound_week])
		@return_week = @ride.ride_weeks.build(date_type: GlobalConstants::Ride_weeks::DATE_TYPES[:return_week])
	end

end
