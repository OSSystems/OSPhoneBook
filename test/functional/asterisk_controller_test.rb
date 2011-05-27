require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../asterisk_mockup_server'
require 'asterisk_monitor'
require 'asterisk_monitor_config'
require 'gserver'

class AsteriskControllerTest < ActionController::TestCase
  test "dial" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id
    assert_redirected_to root_path
    assert_equal "Your call is now being completed.", flash[:notice]
  end

  test "dial with XmlHttpRequest" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    xhr :get, :dial, :id => phone_number.id
    assert_response :success
    assert_equal "Your call is now being completed.", @response.body
  end

  test "dial to inexistend phone number" do
    get :dial, :id => 9999
    assert_response :not_found
  end

  test "lookup number" do
    contact = Contact.new(:name => "Jane Doe")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe", @response.body
  end

  test "lookup number with company" do
    contact = Contact.new(:name => "Jane Doe")
    contact.company = Company.create!(default_hash Company, :name => "ULTRA Corp.")
    hash = default_hash(PhoneNumber, :number => "87654321")
    hash.delete :contact
    contact.phone_numbers = [PhoneNumber.new(hash)]
    contact.save!
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Jane Doe - ULTRA Corp.", @response.body
  end

  test "lookup number with unknown number" do
    PhoneNumber.delete_all
    get :lookup, :phone_number => "87654321"
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "lookup number without number" do
    PhoneNumber.delete_all
    get :lookup
    assert_response :success
    assert_equal "Unknown", @response.body
  end

  test "dial route" do
    assert_routing(
      {:method => :get, :path => '/dial/1'},
      {:controller => 'asterisk', :action => 'dial', :id => "1"}
    )
  end

  test "call id lookup route" do
    assert_routing(
      {:method => :get, :path => '/callerid_lookup'},
      {:controller => 'asterisk', :action => 'lookup'}
    )
  end
end
