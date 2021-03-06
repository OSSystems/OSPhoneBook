class AsteriskController < ApplicationController
  before_action :authenticate_user!, :only => :dial

  include AsteriskHelper

  def dial
    unless current_user_can_dial?
      message = "You can't dial because you do not have an extension set to your user account."
    else
      klass = (params[:dial_type] == "phone" ? PhoneNumber : SkypeContact)
      @phone_number = klass.find params[:id]
      @phone_number.dial current_user.extension
      message = "Your call is now being completed."
    end
    if request.xhr?
      render :plain => message
    else
      flash[:notice] = message
      redirect_to root_path
    end
  end

  def lookup
    phone_number = PhoneNumber.clean_number params[:phone_number].to_s
    skype_user = params[:phone_number].to_s
    relation = Contact.includes(:phone_numbers, :skype_contacts)
    relation = relation.where(["#{PhoneNumber.table_name}.number LIKE ? OR #{SkypeContact.table_name}.username LIKE ?", phone_number, skype_user]).references(:phone_numbers, :skype_contacts)
    contacts = relation.distinct

    if contacts.empty?
      render :plain => "Unknown"
      return
    end

    contact = contacts[0]
    if contacts.size == 1
      response = contact.name
      response += " - " + contact.company.name if contact.company
      render :plain => response
      return
    end

    companies = contacts.collect{|c| c.company}
    if companies[0] and companies.all?{|c| c == companies[0]}
      response = contact.company.name
    else
      response = "ERROR: duplicated number"
    end

    render :plain => response
  end
end
