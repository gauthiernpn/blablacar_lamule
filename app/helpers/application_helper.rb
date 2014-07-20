module ApplicationHelper

	def display_base_errors resource
		return '' if (resource.errors.empty?) or (resource.errors[:base].empty?)
		messages = resource.errors[:base].map { |msg| content_tag(:p, msg) }.join
		html = <<-HTML
    <div class="alert alert-error alert-block">
      <button type="button" class="close" data-dismiss="alert">&#215;</button>
      #{messages}
    </div>
		HTML
		html.html_safe
	end

	def set_date_style(date)
		date.present? ? date.strftime("%a %d %b %Y - %I:%M %p") : ""
		# Thursday 12 June - 03:00
	end

	def set_full_month_date_time_style(date)
		date.present? ? date.strftime("%A %d %B %Y - %I:%M %p") : ""
		# Thursday 12 June - 03:00
	end

	def link_to_add_fields(name, f, association, css_class= "")
		new_object = f.object.send(association).klass.new
		id = new_object.object_id
		fields = f.fields_for(association, new_object, child_index: id) do |builder|
			render(association.to_s.singularize + "_fields", f: builder, parent_obj: f.object, current_model: association.to_s)
		end
		link_to(name, '#', class: "add_fields #{css_class}", data: { id: id, fields: fields.gsub("\n", "") })
	end
end
