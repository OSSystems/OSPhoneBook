class ApplicationController < ActionController::Base
  protect_from_forgery

  [ActionController::UnknownController,
   ActionController::UnknownAction,
   ActionController::RoutingError,
   ActiveRecord::RecordNotFound].each do |exception|
    rescue_from exception, :with => :process_404
  end

  protected
  def process_404
    if request.xhr?
      render :text => "<p class=notice>The page you were looking for does not exist, or was moved.<p>", :status => 404
    else
      render "/404.haml", :status => :not_found
    end
  end
end
