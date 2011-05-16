require File.dirname(__FILE__) + '/../test_helper'

class ContactSearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_template "index"
  end

  test "should get empty search" do
    get :search
    assert_response :success
    assert_equal "{\"data\":[],\"suggestions\":[],\"query\":\"\"}", @response.body
  end

  test "should get search with a simple term" do
    contact = Contact.create!(default_hash(Contact))
    get :search, :query => "John"
    assert_response :success
    assert_equal "{\"data\":[[\"#{contact_path(contact)}\",\"Placebo S.A\",[],[]]],\"suggestions\":[\"John Doe\"],\"query\":\"John\"}", @response.body
  end

  test "index route" do
    assert_routing(
      {:method => :get, :path => '/'},
      {:controller => 'contact_search', :action => 'index'}
    )
  end

  test "search route" do
    assert_routing(
      {:method => :get, :path => '/search'},
      {:controller => 'contact_search', :action => 'search'}
    )
  end
end
