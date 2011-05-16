class ContactsController < ApplicationController
  before_filter :get_contact, :only => [:show, :edit, :update]

  def show
  end

  def new
    @contact = Contact.new
  end

  def create
    @contact = Contact.new(params[:contact])
    if @contact.save
      flash[:notice] = "Contact created."
      redirect_to root_path
    else
      render "new", :status => :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @contact.update_attributes params[:contact]
      flash[:notice] = "Contact updated."
      redirect_to root_path
    else
      render "edit", :status => :unprocessable_entity
    end
  end

  private
  def get_contact
    @contact = Contact.find params[:id]
  end
end
