module ApplicationHelper
  APP_NAME = "O.S. PhoneBook"
  def show_errors_for(model)
    model.errors.empty? ? "" : render(:partial => "errors/errors", :locals => {:model => model})
  end

  def title(*args)
    if args.empty?
      @title ? @title.compact.join(' - ') : ""
    else
      @title ||= []
      @title += args
    end
  end

  def html_title(*args)
    if args.empty?
      html_title = [APP_NAME]
      html_title += @html_title.blank? ? @title : @html_title
      html_title.compact.join(' - ')
    else
      @html_title ||= []
      @html_title += args
    end
  end
end
