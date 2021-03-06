require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require 'asterisk_dial_up'

class AsteriskMonitorTest < ActiveSupport::TestCase
  class Dialer
    include AsteriskDialUp

    def initialize(extension)
      @extension = extension
    end

    def dial(target_number)
      dial_asterisk(@extension, target_number)
    end
  end

  setup do
    @dialer = Dialer.new('1000')
  end

  teardown :stop_asterisk_mock_server

  test "dial number" do
    server = start_asterisk_mock_server
    assert @dialer.dial("05312345678")
    assert_equal "05312345678", server.last_dialed_to
    assert_equal "SIP/1000", server.last_dialed_from
  end

  test "dial number with invalid username or password" do
    server = start_asterisk_mock_server('push-me', 'and-then-just-touch-me')
    Rails.application.config.asterisk_monitor[:port] = server.port
    e = assert_raises AsteriskDialUp::AuthenticationError do
      assert @dialer.dial("05312345678")
    end
    assert_equal 'Asterisk username or password is invalid.', e.message
    assert_nil server.last_dialed_to
    assert_nil server.last_dialed_from
  end
end
