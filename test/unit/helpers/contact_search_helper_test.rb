require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContactSearchHelperTest < ActionView::TestCase
  test "empty search without contacts" do
    Contact.delete_all
    assert_equal({:data => [], :query => "", :suggestions => []}, ContactSearchHelper.search_for_contacts(""))
  end

  test "empty search with one contact" do
    Contact.create!(default_hash(Contact))
    assert_equal({:data => [], :query => "", :suggestions => []}, ContactSearchHelper.search_for_contacts(""))
  end

  test "search without contacts" do
    Contact.delete_all
    assert_equal({:data => [[new_contact_path(:contact => {:name => "John"}), "", [], []]], :query => "John", :suggestions => ["Create a new contact for 'John'..."]}, ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with one contact" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "John", :suggestions => ["John Doe", "Create a new contact for 'John'..."], :data => [[contact_path(contact), "Placebo S.A", [], []], [new_contact_path(:contact => {:name => "John"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with blank space" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "  John", :suggestions => ["John Doe", "Create a new contact for 'John'..."], :data => [[contact_path(contact), "Placebo S.A", [], []],[new_contact_path(:contact => {:name => "John"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("  John"))
  end

  test "search by company" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "Placebo S.A", :suggestions => ["John Doe", "Create a new contact for 'Placebo S.A'..."], :data => [[contact_path(contact), "Placebo S.A", [], []],[new_contact_path(:contact => {:name => "Placebo S.A"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Placebo S.A"))
  end

  test "search by company with middle of string" do
    company = Company.create!(:name => "UltraCompany")
    contact = Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "acom", :suggestions => ["John Doe", "Create a new contact for 'acom'..."], :data => [[contact_path(contact), "UltraCompany", [], []],[new_contact_path(:contact => {:name => "acom"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("acom"))
  end

  test "search with string from the middle of the name" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "oh", :suggestions => ["John Doe", "Create a new contact for 'oh'..."], :data => [[contact_path(contact), "Placebo S.A", [], []],[new_contact_path(:contact => {:name => "oh"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("oh"))
  end

  test "search with different string case" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "DOE", :suggestions => ["John Doe", "Create a new contact for 'DOE'..."], :data => [[contact_path(contact), "Placebo S.A", [], []],[new_contact_path(:contact => {:name => "DOE"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("DOE"))
  end

  test "search with no matching string" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "Jane", :suggestions => ["Create a new contact for 'Jane'..."], :data => [[new_contact_path(:contact => {:name => "Jane"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search with no matching string with telephone" do
    contact = Contact.create!(default_hash(Contact))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    assert_equal({:query => "Jane", :suggestions => ["Create a new contact for 'Jane'..."], :data => [[new_contact_path(:contact => {:name => "Jane"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search with two contacts" do
    contact1 = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    contact2 = Contact.create!(default_hash(Contact, :name => "John Doe"))
    assert_equal({:query => "Doe", :suggestions => ["Jane Doe", "John Doe", "Create a new contact for 'Doe'..."], :data => [[contact_path(contact1), "Placebo S.A", [], []], [contact_path(contact2), "", [], []], [new_contact_path(:contact => {:name => "Doe"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Doe"))
  end

  test "search with two contacts returning only one" do
    Contact.create!(default_hash(Contact, :name => "John Doe"))
    contact = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    assert_equal({:query => "Jane", :suggestions => ["Jane Doe", "Create a new contact for 'Jane'..."], :data => [[contact_path(contact), "", [], []], [new_contact_path(:contact => {:name => "Jane"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search using tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.save!
    contact.reload
    assert_equal({:query => "Abnormals", :suggestions => ["Jane Doe", "Create a new contact for 'Abnormals'..."], :data => [[contact_path(contact), "Placebo S.A", [], ["Abnormals"]], [new_contact_path(:contact => {:name => "Abnormals"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Abnormals"))
  end

  test "search using two tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "Ab", :suggestions => ["Jane Doe", "Create a new contact for 'Ab'..."], :data => [[contact_path(contact), "Placebo S.A", [], ["Abnormals", "Absents"]], [new_contact_path(:contact => {:name => "Ab"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("Ab"))
  end

  test "search matching name and tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "a", :suggestions => ["Jane Doe", "Create a new contact for 'a'..."], :data => [[contact_path(contact), "Placebo S.A", [], ["Abnormals", "Absents"]], [new_contact_path(:contact => {:name => "a"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("a"))
  end

  test "search with different string case for tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "AB", :suggestions => ["Jane Doe", "Create a new contact for 'AB'..."], :data => [[contact_path(contact), "Placebo S.A", [], ["Abnormals", "Absents"]], [new_contact_path(:contact => {:name => "AB"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("AB"))
  end

  test "search using phone number" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    contact.reload
    assert_equal({:query => "1234", :suggestions => ["Jane Doe", "Create a new contact for '1234'..."], :data => [[contact_path(contact), "Placebo S.A", ["(012) 1234-5678"], []], [new_contact_path(:contact => {:name => "1234"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("1234"))
  end

  test "search using phone number with symbols" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    contact.reload
    assert_equal({:query => "1234.5678", :suggestions => ["Jane Doe", "Create a new contact for '1234.5678'..."], :data => [[contact_path(contact), "Placebo S.A", ["(012) 1234-5678"], []], [new_contact_path(:contact => {:name => "1234.5678"}), "", [], []]]}, ContactSearchHelper.search_for_contacts("1234.5678"))
  end
end
