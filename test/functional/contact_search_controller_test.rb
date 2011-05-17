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
    assert_equal "{\"data\":[[\"/contacts/#{contact.id}\",\"Placebo S.A\",[],[]],[\"/contacts/new?contact[name]=John\",\"\",[],[]]],\"suggestions\":[\"John Doe\",\"Create a new contact for 'John'...\"],\"query\":\"John\"}", @response.body
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
