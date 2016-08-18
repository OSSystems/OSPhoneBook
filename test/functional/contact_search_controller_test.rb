require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContactSearchControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_template "index"
  end

  test "should get empty search" do
    get :search
    assert_response :success
    assert assigns(:query_results).empty?
    assert_equal 'application/json', @response.content_type
  end

  test "should get search with a simple term" do
    contact = Contact.create!(default_hash(Contact))
    get :search, :term => "John"
    assert_response :success
    expected = [{
                  label: "John Doe",
                  data: [
                    "/contacts/#{contact.id}","Placebo S.A",
                     [],
                     []],
                }, {
                  label: "Create a new contact for 'John'...",
                  data: [
                    "/contacts/new?contact%5Bname%5D=John",
                    "",
                    [],
                    []]
                }]
    assert_equal(expected, assigns(:query_results))
    assert_equal 'application/json', @response.content_type
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
