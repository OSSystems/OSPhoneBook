class ContactsController < ApplicationController
  before_filter :get_contact, :only => [:show, :edit, :update]

  def show
  end

  def edit
  end

  def update
    if @contact.update_attributes params[:contact]
      flash[:notice] = "Contact updated."
      redirect_to root_path
    else
      render "edit"
    end
  end

  private
  def get_contact
    @contact = Contact.find params[:id]
  end
end
