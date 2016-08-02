require File.expand_path(File.dirname(__FILE__) + '/../test_helper')
require File.expand_path(File.dirname(__FILE__) + '/../asterisk_mockup_server')
require 'asterisk_monitor'
require 'asterisk_monitor_config'

class SkypeContactTest < ActiveSupport::TestCase
  test "create Skype contact" do
    skype_contact = SkypeContact.create(default_hash(SkypeContact))
    assert skype_contact.valid?, "Unexpected errors found: " + skype_contact.errors.full_messages.join(", ")
    assert !skype_contact.new_record?
  end

  test "try to create skype contact with invalid username" do
    # nil:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => nil))
    assert_equal "Username can't be blank", skype_contact.errors.full_messages.join(", ")

    # blank:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => ""))
    assert_equal "Username can't be blank", skype_contact.errors.full_messages.join(", ")

    # too short:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => "abcde"))
    assert_equal "Username is too short (minimum is 6 characters)", skype_contact.errors.full_messages.join(", ")

    # too long:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => "averylongusernamewichmustnotbevalid"))
    assert_equal "Username is too long (maximum is 32 characters)", skype_contact.errors.full_messages.join(", ")

    # does not start with a letter, but with number:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => "1abcde"))
    assert_equal "Username must start with a letter", skype_contact.errors.full_messages.join(", ")

    # does not start with a letter, but with punctuation:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => "1abcde"))
    assert_equal "Username must start with a letter", skype_contact.errors.full_messages.join(", ")

    # contains invalid punctuation:
    skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => "a%$#!*"))
    assert_equal "Username must contain only letters, numbers and the following punctuation: '.', ',', '-' and '_'", skype_contact.errors.full_messages.join(", ")
  end

  test "create skype contact with valid usernames" do
    ["abcdef", "a1b2c3", "a.,-,2"].each do |username|
      skype_contact = SkypeContact.create(default_hash(SkypeContact, :username => username))
      assert skype_contact.valid?, "Unexpected errors found: " + skype_contact.errors.full_messages.join(", ")
    end
  end

  test "skype contacts has contact accessor" do
    assert_nothing_raised do
      assert !SkypeContact.create(default_hash SkypeContact).contact.nil?
    end
  end

  test "dial skype user" do
    port = AsteriskMonitorConfig.host_data[:port]
    stop_asterisk_mock_server

    server = start_asterisk_mock_server "foo", "bar"
    skype_contact = SkypeContact.create!(default_hash(SkypeContact, :username => "john.doe"))
    assert skype_contact.dial("0001")
    assert_equal "Skype/john.doe", server.last_dialed_to
    assert_equal "SIP/0001", server.last_dialed_from
  end
end
