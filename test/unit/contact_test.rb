require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContactTest < ActiveSupport::TestCase
  test "create contact" do
    contact = Contact.create(default_hash(Contact))
    assert contact.valid?
    assert !contact.new_record?
  end

  test "create contact without company" do
    contact = Contact.create(default_hash(Contact, :company => nil))
    assert contact.valid?
    assert !contact.new_record?
  end

  test "try to create contact without name" do
    contact = Contact.create(default_hash(Contact, :name => nil))
    assert_equal "Name can't be blank", contact.errors.full_messages.join(", ")
  end

  test "try to repeat contact name" do
    contact = Contact.create(default_hash(Contact))
    assert contact.valid?
    assert !contact.new_record?
    contact = Contact.create(default_hash(Contact, :company => contact.company))
    assert_equal "Name has already been taken", contact.errors.full_messages.join(", ")
  end

  test "contact has contacts accessor" do
    assert_nothing_raised do
      assert Contact.create(default_hash(Contact)).phone_numbers.empty?
    end
  end

  test "contact has tag accessor" do
    assert_nothing_raised do
      assert Contact.create(default_hash(Contact)).tags.empty?
    end
  end
end
