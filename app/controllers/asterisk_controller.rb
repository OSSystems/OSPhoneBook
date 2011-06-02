class AsteriskController < ApplicationController
  before_filter :authenticate_user!, :only => :dial

  include AsteriskHelper

  def dial
    unless current_user_can_dial?
      message = "You can't dial because you do not have an extension set to your user account."
    else
      @phone_number = PhoneNumber.find params[:id]
      @phone_number.dial current_user.extension
      message = "Your call is now being completed."
    end
    if request.xhr?
      render :text => message
    else
      flash[:notice] = message
      redirect_to root_path
    end
  end

  def lookup
    phone_number = PhoneNumber.clean_number params[:phone_number].to_s
    contacts = Contact.includes(:phone_numbers).where(:phone_numbers => {:number => phone_number}).all.uniq

    if contacts.empty?
      render :text => "Unknown"
      return
    end

    contact = contacts[0]
    if contacts.size == 1
      response = contact.name
      response += " - " + contact.company.name if contact.company
      render :text => response
      return
    end

    companies = contacts.collect{|contact| contact.company}
    if companies.all?{|c| c == companies[0]}
      response = contact.company.name
    else
      response = "ERROR: duplicated number"
    end

    render :text => response
  end
end
