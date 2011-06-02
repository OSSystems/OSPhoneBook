class ContactsController < ApplicationController
  before_filter :authenticate_user!, :except => :show
  before_filter :get_contact, :only => [:show, :show_javascript, :edit, :update, :tag_remove]
  after_filter :clear_unused_tags, :only => :update

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
    set_tags_in_object
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
    set_tags_in_object
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

  def tag_search
    query_results = TagSearchHelper.search_for_tags(params[:query].to_s)
    render :json => query_results.to_json
  end

  def set_tags
    tag_names = (params[:tags] or []).collect{|name| name.to_s}
    tag_names = [tag_names] unless tag_names.is_a?(Array)
    tag_names += tag_names.select{|name| !name.to_s.blank?}
    @tags = [Tag.find_or_create_by_name(params[:add_tag].to_s.strip)]
    @tags += Tag.find_all_by_name(tag_names)
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
    if not params[:contact].blank?
      if not params[:company_search_field].blank?
        company = Company.find_or_create_by_name(params[:company_search_field])
        @contact.company = company
      else
        @contact.company = nil
      end
    end
  end

  def set_tags_in_object
    if not params[:tags].blank?
      tags = []
      params[:tags].collect{|name| name.to_s.strip}.each do |name|
        tags << Tag.find_or_create_by_name(name)
      end
      @contact.tags = tags
    else
      @contact.tags = []
    end
  end

  def process_404
    (params[:action] == "show_javascript" ? head(:status => :not_found) : super)
  end

  def clear_unused_tags
    rel = Tag.joins("LEFT JOIN contacts_tags ON tags.id = contacts_tags.tag_id")
    rel.where(:contacts_tags => {:id => nil}).destroy_all
  end
end
