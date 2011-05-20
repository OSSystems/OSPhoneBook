require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../asterisk_mockup_server'
require 'asterisk_monitor'

class AsteriskMonitorTest < ActiveSupport::TestCase
  USERNAME = "USER"
  PASSWORD = "PASS"

  def teardown
    @mockup.stop if @mockup
  end

  test "connection without port" do
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD).start
    assert GServer.in_service?(5038)
    am = AsteriskMonitor.new
    assert_difference "@mockup.connections", 1 do
      am.connect '127.0.0.1'
      am.login USERNAME, PASSWORD
    end
  end

  test "connection with port" do
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD, [10000]).start
    assert GServer.in_service?(10000)
    am = AsteriskMonitor.new
    assert_difference "@mockup.connections", 1 do
      am.connect '127.0.0.1', 10000
      am.login USERNAME, PASSWORD
    end
  end

  test "disconnection" do
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD, [10000]).start
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
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD).start
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert am.login(USERNAME, PASSWORD)
    assert am.logged?
  end

  test "failed login" do
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD).start
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert !am.login("foo", "bar")
    assert !am.logged?
  end

  test "originate call" do
    @mockup = AsteriskMockupServer.new(USERNAME, PASSWORD).start
    am = AsteriskMonitor.new
    am.connect '127.0.0.1'
    assert !am.logged?
    assert am.login(USERNAME, PASSWORD)
    assert am.logged?
    assert am.originate *%w(channel context exten priority timeout)
  end
end
