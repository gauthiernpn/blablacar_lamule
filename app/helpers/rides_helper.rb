module RidesHelper

	def date_in_today_format(date)
		if (Time.now).end_of_day > date
			return "Today - #{date.strftime('%H:%M')}"
		elsif (Time.now + 1.day).end_of_day > date
			return "Tomorrow - #{date.strftime('%H:%M')}"
		else
			return date.strftime("%A %e %B - %H:%M")
		end
	end

  def sort_btn_active(param_val, its_val1, its_val2=nil)
    param_val == its_val1 || param_val == its_val2 ? "active" : ""
  end
end
