class AsteriskDialController < ApplicationController
  def dial
    @phone_number = PhoneNumber.find params[:id]
    @phone_number.dial
    message = "Your call is now being completed."
    if request.xhr?
      render :text => message
    else
      flash[:notice] = message
      redirect_to root_path
    end
  end
end
