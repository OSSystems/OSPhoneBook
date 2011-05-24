class ContactsController < ApplicationController
  before_filter :get_contact, :only => [:show, :show_javascript, :edit, :update]

  def show
    @dialing_options = ContactsHelper.get_dialing_options(@contact)
  end

  def show_javascript
    @dialing_options = ContactsHelper.get_dialing_options(@contact)
    render "contact_show_javascript", :layout => false, :content_type => "text/javascript"
  end

  def new
    @contact = Contact.new((params[:contact] or {}))
  end

  def create
    @contact = Contact.new(params[:contact])
    set_company
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
    @contact.attributes = params[:contact]
    set_company
    if @contact.save
      flash[:notice] = "Contact updated."
      redirect_to root_path
    else
      render "edit", :status => :unprocessable_entity
    end
  end

  def company_search
    query_results = CompanySearchHelper.search_for_companies(params[:query].to_s)
    render :json => query_results.to_json
  end

  private
  def get_contact
    @contact = Contact.find params[:id]
  end

  def set_company
    if not params[:contact].blank?
      if not params[:company_search_field].blank?
        company = Company.find_or_create_by_name(params[:company_search_field])
        @contact.company = company
      else
        @contact.company = nil
      end
    end
  end

  def process_404
    (params[:action] == "show_javascript" ? head(:status => :not_found) : super)
  end
end
