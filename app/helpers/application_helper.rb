module ApplicationHelper
  def show_errors_for(model)
    render :partial => "errors/errors", :locals => {:model => model}
  end
end
