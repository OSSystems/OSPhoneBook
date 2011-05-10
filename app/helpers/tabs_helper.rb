module TabsHelper
  def render_tabs
    user_tabs = []
    user_tabs << ["Search", root_path]

    render :partial => "tabs/tabs", :locals => {:tabs => user_tabs}
  end
end
