require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../asterisk_mockup_server')
require 'asterisk_monitor'

class AsteriskMonitorTest < ActiveSupport::TestCase
  USERNAME = "USER"
  PASSWORD = "PASS"

  teardown :stop_asterisk_mock_server

  test "connection without port" do
    server = start_asterisk_mock_server USERNAME, PASSWORD
    assert OpenPortChecker.port_open?('127.0.0.1', server.port)
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1'
      am.login USERNAME, PASSWORD
    end
  end

  test "connection with port" do
    server = start_asterisk_mock_server USERNAME, PASSWORD
    assert OpenPortChecker.port_open?('127.0.0.1', server.port)
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1', server.port
      am.login USERNAME, PASSWORD
    end
  end

  test "disconnection" do
    server = start_asterisk_mock_server USERNAME, PASSWORD
    assert OpenPortChecker.port_open?('127.0.0.1', server.port)
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1'
      assert am.disconnect
    end
  end

  test "disconnection without connection" do
    assert_not OpenPortChecker.port_open?('127.0.0.1', 5068)
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      assert_not am.disconnect
    end
  end

  test "login" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1'
      assert_not am.logged?
      assert am.login(USERNAME, PASSWORD)
      assert am.logged?
    end
  end

  test "failed login" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1'
      assert_not am.logged?
      assert_not am.login("foo", "bar")
      assert_not am.logged?
    end
  end

  test "originate call" do
    start_asterisk_mock_server USERNAME, PASSWORD
    am = AsteriskMonitor.new
    ensure_disconnect(am) do
      am.connect '127.0.0.1'
      assert_not am.logged?
      assert am.login(USERNAME, PASSWORD)
      assert am.logged?
      assert am.originate *%w(channel context exten priority timeout)
    end
  end

  private
  def ensure_disconnect(asterisk_monitor)
    begin
      yield
    ensure
      asterisk_monitor.disconnect
    end
  end
end
