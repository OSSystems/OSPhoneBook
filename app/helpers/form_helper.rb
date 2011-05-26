module FormHelper
  def link_remove_field(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  end

  def link_add_field(name, f, association, options)
    new_object = f.object.class.reflect_on_association(association).klass.new
    partial = (options[:partial] or association.to_s.singularize + "_fields")
    container = (options[:container] or 'this')
    fields = f.fields_for(association, new_object, :field_index => "new_#{association}") do |builder|
      render(:partial => partial, :locals => {:f => builder})
    end
    link_to_function(name, "add_fields('#{container}', \"#{association}\", \"#{escape_javascript(fields)}\")", options[:html])
  end

  # def link_remove_field(name, f, options = {})
  #   f.hidden_field(:_destroy) + link_to_function(name, "remove_fields(this)", options)
  # end

  # def link_add_field(name, f, association, options)
  #   new_object = f.object.class.reflect_on_association(association).klass.new
  #   options[:partial] ||= association.to_s.singularize + "_fields"
  #   options[:link] ||= 'this'
  #   fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
  #     render(:partial => options[:partial], :locals => {:f => builder})
  #   end
  #   link_to_function(name, "add_fields(#{options[:link]}, \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  # end
end
