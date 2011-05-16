require File.dirname(__FILE__) + '/../test_helper'

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
    assert_nil phone_number.read_attribute(:number)

    # no number, blank:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => ""))
    assert_equal "", phone_number.read_attribute(:number)

    # Direct Distance Dialing:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "53 1234-5678"))
    assert_equal "05312345678", phone_number.read_attribute(:number)

    # Direct Distance Dialing, with zero:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "0 53 1234-5678"))
    assert_equal "05312345678", phone_number.read_attribute(:number)

    # International Direct Distance Dialing, with leading zeros:
    phone_number = PhoneNumber.create!(default_hash(PhoneNumber, :number => "00 55 53 12345-678"))
    assert_equal "00555312345678", phone_number.read_attribute(:number)
  end

  test "get prettyfied number" do
    # no number, nil:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => nil))
    assert_nil phone_number.read_attribute(:number)

    # no number, blank:
    phone_number = PhoneNumber.new(default_hash(PhoneNumber, :number => ""))
    assert_equal "", phone_number.read_attribute(:number)

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
end
