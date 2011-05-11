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
    get :search, :search_field => "John"
    assert_response :success
    assert_equal "{\"data\":[#{contact.id}],\"suggestions\":[\"John Doe\"],\"query\":\"John\"}", @response.body
  end
end
