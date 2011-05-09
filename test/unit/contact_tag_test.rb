require File.dirname(__FILE__) + '/../test_helper'

class ContactTagTest < ActiveSupport::TestCase
  test "create contact_tag" do
    contact_tag = ContactTag.create(default_hash(ContactTag))
    assert contact_tag.valid?
    assert !contact_tag.new_record?
  end

  test "try to create contact tag without contact" do
    contact_tag = ContactTag.create(default_hash(ContactTag, :contact => nil))
    assert_equal "Contact can't be blank", contact_tag.errors.full_messages.join(", ")
  end

  test "try to create contact tag without tag" do
    contact_tag = ContactTag.create(default_hash(ContactTag, :tag => nil))
    assert_equal "Tag can't be blank", contact_tag.errors.full_messages.join(", ")
  end

  test "contact tag has contact accessor" do
    contact_tag = ContactTag.create(default_hash(ContactTag))
    assert_nothing_raised do
      assert_equal Contact.first, contact_tag.contact
    end
  end

  test "contact tag has tag accessor" do
    contact_tag = ContactTag.create(default_hash(ContactTag))
    assert_nothing_raised do
      assert_equal Tag.first, contact_tag.tag
    end
  end
end
