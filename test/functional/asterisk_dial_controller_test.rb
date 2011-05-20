require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../asterisk_mockup_server'
require 'asterisk_monitor'
require 'asterisk_monitor_config'
require 'gserver'

class AsteriskDialControllerTest < ActionController::TestCase
  test "dial" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)
    mockup = AsteriskMockupServer.new("foo", "bar").start

    phone_number = PhoneNumber.create!(default_hash(PhoneNumber))
    get :dial, :id => phone_number.id
    assert_response :success
    assert_equal "Your call is now being completed.", @response.body
  end

  test "dial to inexistend phone number" do
    get :dial, :id => 9999
    assert_response :not_found
  end

  test "dial route" do
    assert_routing(
      {:method => :get, :path => '/dial/1'},
      {:controller => 'asterisk_dial', :action => 'dial', :id => "1"}
    )
  end
end
