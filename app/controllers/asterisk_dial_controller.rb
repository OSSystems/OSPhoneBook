class AsteriskDialController < ApplicationController
  def dial
    @phone_number = PhoneNumber.find params[:id]
    @phone_number.dial
    render :text => "Your call is now being completed."
  end
end
