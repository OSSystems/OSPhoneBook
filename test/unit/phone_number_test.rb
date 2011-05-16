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
end
