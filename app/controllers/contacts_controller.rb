class ContactsController < ApplicationController
  def show
    @contact = Contact.find_by_id params[:id]
    if @contact.nil?
      render "/404.haml", :status => :not_found
    end
  end

  def edit
    @contact = Contact.find_by_id params[:id]
    if @contact.nil?
      render "/404.haml", :status => :not_found
    end
  end
end
