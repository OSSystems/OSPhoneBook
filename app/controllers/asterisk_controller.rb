class AsteriskController < ApplicationController
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

  def lookup
    @phone = PhoneNumber.find_by_number params[:phone_number].to_s
    if @phone
      response = @phone.contact.name
      response += " - " + @phone.contact.company.name if @phone.contact.company
    else
      response = "Unknown"
    end
    render :text => response
  end
end
