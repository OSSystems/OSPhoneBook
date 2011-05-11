class ContactSearchController < ApplicationController
  def index
  end

  def search
    query_results = ContactSearchHelper.search_for_contacts(params[:search_field].to_s)
    render :json => query_results.to_json
  end
end
