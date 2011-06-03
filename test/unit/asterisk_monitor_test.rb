require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../asterisk_mockup_server')
require 'asterisk_monitor'

class AsteriskMonitorTest < ActiveSupport::TestCase
  USERNAME = "USER"
  PASSWORD = "PASS"

  test "connection without port" do
    server = start_asterisk_mock_server USERNAME, PASSWORD
    assert GServer.in_service?(5038)
    am = AsteriskMonitor.new
    assert_difference "server.connections", 1 do
      am.connect '127.0.0.1'
      am.login USERNAME, PASSWORD
    end
  end

  test "connection with port" do
    server = start_asterisk_mock_server USERNAME, PASSWORD, 10000
    assert GServer.in_service?(10000)
    am = AsteriskMonitor.new
    assert_difference "server.connections", 1 do
      am.connect '127.0.0.1', 10000
      am.login USERNAME, PASSWORD
    end
  end

  test "disconnection" do
    start_asterisk_mock_server USERNAME, PASSWORD, 10000
    assert GServer.in_service?(10000)
    am = AsteriskMonitor.new
    am.connect '127.0.0.1', 10000
    assert am.disconnect
  end

  test "disconnection without connection" do
    am = AsteriskMonitor.new
    assert !am.disconnect
  end

  test "login" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert am.login(USERNAME, PASSWORD)
    assert am.logged?
  end

  test "failed login" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert !am.login("foo", "bar")
    assert !am.logged?
  end

  test "originate call" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert am.login(USERNAME, PASSWORD)
    assert am.logged?
    assert am.originate *%w(channel context exten priority timeout)
  end
end
