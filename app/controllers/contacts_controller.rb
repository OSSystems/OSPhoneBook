class ContactsController < ApplicationController
  before_action :authenticate_user!, :except => :show
  before_action :get_contact, :only => [:show, :show_javascript, :edit, :update, :tag_remove]
  after_action :clear_unused_tags_and_companies, :only => :update
  skip_before_action :verify_authenticity_token, only: [:show_javascript]

  def show
    @dialing_options = ContactsHelper.get_dialing_options(@contact)
  end

  def new
    @contact = Contact.new((contact_params or {}))
  end

  def create
    @contact = Contact.new(contact_params)
    save("new", "Contact created.")
  end

  def edit
  end

  def update
    @contact.attributes = contact_params
    save("edit", "Contact updated.")
  end

  def company_search
    @query_results = CompanySearchHelper.search_for_companies(params[:term].to_s)
    render :json => @query_results.to_json
  end

  def tag_search
    @query_results = TagSearchHelper.search_for_tags(params[:term].to_s)
    render :json => @query_results.to_json
  end

  def set_tags
    tag_names = (params[:tags] or []).collect{|name| name.to_s}
    tag_names = [tag_names] unless tag_names.is_a?(Array)
    tag_names += tag_names.select{|name| !name.to_s.blank?}
    @tags = [Tag.find_or_create_by(name: params[:add_tag].to_s.strip)]
    @tags += Tag.where(name: tag_names).load
    @tags = @tags.select{|tag| tag.valid?}
    @tags.uniq!
    @tags.sort!
    render :partial => "tags/tags", :locals => {:tags => @tags}
  end

  private
  def get_contact
    @contact = Contact.find params[:id]
  end

  def set_company
    if not params.blank?
      if not params[:company_search_field].blank?
        company = Company.find_or_create_by(name: params[:company_search_field])
        @contact.company = company
      else
        @contact.company = nil
      end
    end
  end

  def set_tags_in_object
    if not params[:tags].blank?
      tags = []
      params[:tags].each do |name|
        tags << Tag.find_or_create_by(name: name.to_s.strip)
      end
      @contact.tags = tags
    else
      @contact.tags = []
    end
  end

  def process_404
    (params[:action] == "show_javascript" ? head(:status => :not_found) : super)
  end

  def clear_unused_tags_and_companies
    Tag.includes(:contacts_tags).where(:contacts_tags => {:id => nil}).destroy_all
    Company.includes(:contacts).where(:contacts => {:id => nil}).destroy_all
  end

  private
  def contact_params
    params.fetch(:contact, {}).permit(:name, :comments, :company_id, :phone_numbers_attributes => [:id, :number, :phone_type, :_destroy], :skype_contacts_attributes => [:id, :username, :_destroy])
  end

  def save(error_form, success_message)
    begin
      Contact.transaction do
        set_company
        @contact.save!
        set_tags_in_object
        flash[:notice] = success_message
        redirect_to root_path
      end
    rescue ActiveRecord::RecordInvalid => e
      # Keep the tags when rendering the form again:
      set_tags_in_object
      render error_form, :status => :unprocessable_entity
    end
  end
end
