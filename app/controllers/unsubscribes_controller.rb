class UnsubscribesController < ApplicationController

	layout "profile", only: [:account, :delete_account]

	def account
		@unsubscribe = Unsubscribe.new
	end

	def delete_account
		begin
			@unsubscribe = current_user.build_unsubscribe(unsubscribe_params)
			if @unsubscribe.save
				UserMailer.delete_account(@unsubscribe.unsubscribe_reason.name, @unsubscribe.comment, current_user).deliver
				current_user.destroy
				return redirect_to root_path, notice: t('.success')
			else
				return render 'account'
			end
		rescue Exception => e
			puts "=== Delete Account ==="
			puts e
			flash[:danger] = t('.failed')
			return redirect_to account_unsubscribes_path
		end
	end

	private
	def unsubscribe_params
		params.require(:unsubscribe).permit(:unsubscribe_reason_id, :comment, :recommend)
	end

end
