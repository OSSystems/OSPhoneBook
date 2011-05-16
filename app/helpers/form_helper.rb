module FormHelper
  def link_remove_child(name, f, options = {})
    f.hidden_field(:_destroy) + link_to_function(name, "remove_childs(this)", options)
  end

  def link_add_child(name, f, association, options)
    new_object = f.object.class.reflect_on_association(association).klass.new
    options[:partial] ||= association.to_s.singularize + "_childs"
    options[:container] ||= 'this'
    fields = f.fields_for(association, new_object, :child_index => "new_#{association}") do |builder|
      render(:partial => options[:partial], :locals => {:f => builder})
    end
    link_to_function(name, "add_childs('#{options[:container]}', \"#{association}\", \"#{escape_javascript(fields)}\")", options)
  end
end
