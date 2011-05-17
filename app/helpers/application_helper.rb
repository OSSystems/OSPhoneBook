module ApplicationHelper
  def csrf_meta_tag
    if protect_against_forgery?
      %(<meta name="csrf-param" content="#{Rack::Utils.escape_html(request_forgery_protection_token)}">\n<meta name="csrf-token" content="#{Rack::Utils.escape_html(form_authenticity_token)}">).html_safe
    end
  end

  def stylesheet_tag(source, options)
    tag("link", { "rel" => "stylesheet", "type" => Mime::CSS, "media" => "screen", "href" => html_escape(path_to_stylesheet(source)) }.merge(options), true, false)
  end

  def show_errors_for(model)
    render :partial => "errors/errors", :locals => {:model => model}
  end
end
