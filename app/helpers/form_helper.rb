module FormHelper
  def remove_child_link(name, f)
    f.hidden_field(:_destroy) + link_to(name, "javascript:void(0)", :class => "remove_fields")
  end

  def add_child_link(name, f, method, options = {})
    options[:container] ||= method.to_s
    options[:position] ||= "bottom"
    fields = new_child_fields(f, method, options)
    javascript_options = {'data-content' => CGI::escapeHTML(fields),
      'data-method' => method,
      'data-container-id' => options[:container],
      'data-position' => options[:position].to_s,
      :class => "insert_fields"}
    link_to(name, "javascript:void(0)", javascript_options)
  end

  def new_child_fields(form_builder, method, options = {})
    options[:object] ||= form_builder.object.class.reflect_on_association(method).klass.new
    options[:partial] ||= method.to_s.singularize
    options[:form_builder_local] ||= :f
    form_builder.fields_for(method, options[:object], :child_index => "new_#{method}") do |f|
      render(:partial => options[:partial], :locals => { options[:form_builder_local] => f })
    end
  end
end
