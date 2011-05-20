require File.dirname(__FILE__) + '/../test_helper'
require File.dirname(__FILE__) + '/../asterisk_mockup_server'
require 'asterisk_monitor'
require 'asterisk_monitor_config'
require 'gserver'

class PhoneNumberTest < ActiveSupport::TestCase
  test "create phone_number" do
    phone_number = PhoneNumber.create(default_hash(PhoneNumber))
    assert phone_number.valid?, "Unexpected errors found: " + phone_number.errors.full_messages.join(", ")
    assert !phone_number.new_record?
  end

  test "try to create phone_number without phone_type" do
    phone_number = PhoneNumber.create(default_hash(PhoneNumber, :phone_type => nil))
    assert_equal "Phone type can't be blank", phone_number.errors.full_messages.join(", ")
  end

  test "clean number on add" do
    # no number, nil:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => nil))
    assert_nil phone_number.raw_number

    # no number, blank:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => ""))
    assert_equal "", phone_number.raw_number

    # Direct Distance Dialing:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "53 1234-5678"))
    assert_equal "05312345678", phone_number.raw_number

    # Direct Distance Dialing, with zero:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "0 53 1234-5678"))
    assert_equal "05312345678", phone_number.raw_number

    # International Direct Distance Dialing, with leading zeros:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "00 55 53 12345-678"))
    assert_equal "00555312345678", phone_number.raw_number
  end

  test "get prettyfied number" do
    # no number, nil:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => nil))
    assert_nil phone_number.number

    # no number, blank:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => ""))
    assert_equal "", phone_number.number

    # Direct Distance Dialing:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "53 1234-5678"))
    assert_equal "(053) 1234-5678", phone_number.number

    # Direct Distance Dialing, with zero:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "0 53 1234-5678"))
    assert_equal "(053) 1234-5678", phone_number.number

    # International Direct Distance Dialing, with leading zeros:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "00 55 53 12345-678"))
    assert_equal "+555312345678", phone_number.number
  end

  test "dial number" do
    port = AsteriskMonitorConfig.host_data[:port]
    GServer.stop(port) if GServer.in_service?(port)

    mockup = AsteriskMockupServer.new("foo", "bar").start
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "53 1234-5678"))
    assert phone_number.dial
    assert_equal "05312345678", mockup.last_dialed_number
  end
end
