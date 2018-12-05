require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class ContactTest < ActiveSupport::TestCase
  test "create contact" do
    contact = Contact.create(default_hash(Contact))
    assert contact.valid?
    assert_not contact.new_record?
  end

  test "create contact without company" do
    contact = Contact.create(default_hash(Contact, :company => nil))
    assert contact.valid?
    assert_not contact.new_record?
  end

  test "create contact with repeated name but different companies" do
    company_1 = Company.create(default_hash(Company))
    company_2 = Company.create(default_hash(Company))
    hash = default_hash(Contact)

    hash[:company_id] = company_1.id
    contact = Contact.create(hash)
    assert contact.valid?
    assert_not contact.new_record?

    hash[:company_id] = company_2.id
    contact = Contact.create(hash)
    assert contact.valid?
    assert_not contact.new_record?
  end

  test "create contact with repeated name but one in company" do
    company = Company.create(default_hash(Company))
    hash = default_hash(Contact)

    hash[:company_id] = company.id
    contact = Contact.create(hash)
    assert contact.valid?
    assert_not contact.new_record?

    hash[:company_id] = nil
    contact = Contact.create(hash)
    assert contact.valid?
    assert_not contact.new_record?
  end

  test "try to create contact without name" do
    contact = Contact.create(default_hash(Contact, :name => nil))
    assert_equal "Name can't be blank", contact.errors.full_messages.join(", ")
  end

  test "try to repeat contact name" do
    contact = Contact.create(default_hash(Contact))
    assert contact.valid?
    assert_not contact.new_record?
    contact = Contact.create(default_hash(Contact, :name => contact.name, :company => contact.company))
    assert_equal "Name has already been taken", contact.errors.full_messages.join(", ")
  end

  test "try to repeat contact name without company" do
    contact = Contact.create(default_hash(Contact, :company => nil))
    assert contact.valid?
    assert_not contact.new_record?
    contact = Contact.create(default_hash(Contact, :name => contact.name, :company => nil))
    assert_equal "Name has already been taken", contact.errors.full_messages.join(", ")
  end

  test "contact has phone numbers accessor" do
    assert_nothing_raised do
      assert Contact.create(default_hash(Contact)).phone_numbers.empty?
    end
  end

  test "contact has skype contacts accessor" do
    assert_nothing_raised do
      assert Contact.create(default_hash(Contact)).skype_contacts.empty?
    end
  end

  test "contact has tag accessor" do
    assert_nothing_raised do
      assert Contact.create(default_hash(Contact)).tags.empty?
    end
  end

  test "contact accepts nested attributes for phone numbers and skype" do
    hash = default_hash(Contact)
    hash[:phone_numbers_attributes] = {"0" => {:number => "1234", :phone_type => 1}}
    hash[:skype_contacts_attributes] = {"0" => {:username => "abcdef"}}

    assert_nothing_raised do
      contact = Contact.create hash
      assert contact.valid?
      assert_not contact.new_record?
      contact.reload
      assert_equal ["1234"], contact.phone_numbers.collect{|pn| pn.number}
      assert_equal ["abcdef"], contact.skype_contacts.collect{|sc| sc.username}
    end
  end
end
