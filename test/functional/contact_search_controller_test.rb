require File.dirname(__FILE__) + '/../test_helper'

class ContactSearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_template "index"
  end
end
