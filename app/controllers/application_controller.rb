class ApplicationController < ActionController::Base
  protect_from_forgery

  [ActionController::UnknownController,
   ::AbstractController::ActionNotFound,
   ActionController::RoutingError,
   ActiveRecord::RecordNotFound].each do |exception|
    rescue_from exception, :with => :process_404
  end

  protected
  def process_404
    if request.xhr?
      render :text => "<p class=notice>The page you were looking for does not exist, or was moved.<p>", :status => 404
    else
      flash[:notice] = "Please check the address you have typed, and if you cannot access the desired feature contact the system admistrator."
      render "/404", :status => :not_found
    end
  end
end
