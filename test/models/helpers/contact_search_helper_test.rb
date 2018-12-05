require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class ContactSearchHelperTest < ActionView::TestCase
  test "empty search without contacts" do
    Contact.delete_all
    assert ContactSearchHelper.search_for_contacts("").empty?
  end

  test "empty search with one contact" do
    Contact.create!(default_hash(Contact))
    assert ContactSearchHelper.search_for_contacts("").empty?
  end

  test "search without contacts" do
    Contact.delete_all
    assert_equal([{:label => "Create a new contact for 'John'...", :data => [new_contact_path(:contact => {:name => "John"}), "", [], []]}], ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with one contact" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for 'John'...", :data => [new_contact_path(:contact => {:name => "John"}), "", [], []]}], ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with blank space" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for 'John'...", :data => [new_contact_path(:contact => {:name => "John"}), "", [], []]}], ContactSearchHelper.search_for_contacts("  John"))
  end

  test "search by company" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for '#{contact.company.name}'...", :data => [new_contact_path(:contact => {:name => contact.company.name}), "", [], []]}], ContactSearchHelper.search_for_contacts(contact.company.name))
  end

  test "search by company with middle of string" do
    company = Company.create!(:name => "UltraCompany")
    contact = Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), "UltraCompany", [], []]}, {:label => "Create a new contact for 'acom'...", :data => [new_contact_path(:contact => {:name => "acom"}), "", [], []]}], ContactSearchHelper.search_for_contacts("acom"))
  end

  test "search with string from the middle of the name" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for 'oh'...", :data => [new_contact_path(:contact => {:name => "oh"}), "", [], []]}], ContactSearchHelper.search_for_contacts("oh"))
  end

  test "search with different string case" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => contact.name, :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for 'DOE'...", :data => [new_contact_path(:contact => {:name => "DOE"}), "", [], []]}], ContactSearchHelper.search_for_contacts("DOE"))
  end

  test "search with no matching string" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal([{:label => "Create a new contact for 'Jane'...", :data => [new_contact_path(:contact => {:name => "Jane"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search with no matching string with telephone" do
    contact = Contact.create!(default_hash(Contact))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    assert_equal([{:label => "Create a new contact for 'Jane'...", :data => [new_contact_path(:contact => {:name => "Jane"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search with two contacts" do
    contact1 = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    contact2 = Contact.create!(default_hash(Contact, :name => "John Doe"))
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact1), contact1.company.name, [], []]}, {:label => contact2.name, :data => [contact_path(contact2), contact2.company.name, [], []]}, {:label => "Create a new contact for 'Doe'...", :data => [new_contact_path(:contact => {:name => "Doe"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Doe"))
  end

  test "search with two contacts returning only one" do
    Contact.create!(default_hash(Contact, :name => "John Doe"))
    contact = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, [], []]}, {:label => "Create a new contact for 'Jane'...", :data => [new_contact_path(:contact => {:name => "Jane"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search using tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.save!
    contact.tags << Tag.create!(default_hash(Tag))
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, [], [contact.tags[0].name]]}, {:label => "Create a new contact for 'Abnormals'...", :data => [new_contact_path(:contact => {:name => "Abnormals"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Abnormals"))
  end

  test "search using two tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.save!
    contact.tags << Tag.create!(default_hash(Tag))
    contact.tags << Tag.create!(default_hash(Tag, :name => "Absents"))
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, [], [contact.tags[0].name, "Absents"]]}, {:label => "Create a new contact for 'Ab'...", :data => [new_contact_path(:contact => {:name => "Ab"}), "", [], []]}], ContactSearchHelper.search_for_contacts("Ab"))
  end

  test "search matching name and tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.save!
    contact.tags << Tag.create!(default_hash(Tag))
    contact.tags << Tag.create!(default_hash(Tag, :name => "Absents"))
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, [], [contact.tags[0].name, "Absents"]]}, {:label => "Create a new contact for 'a'...", :data => [new_contact_path(:contact => {:name => "a"}), "", [], []]}], ContactSearchHelper.search_for_contacts("a"))
  end

  test "search with different string case for tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.save!
    contact.tags << Tag.create!(default_hash(Tag))
    contact.tags << Tag.create!(default_hash(Tag, :name => "Absents"))
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, [], [contact.tags[0].name, "Absents"]]}, {:label => "Create a new contact for 'AB'...", :data => [new_contact_path(:contact => {:name => "AB"}), "", [], []]}], ContactSearchHelper.search_for_contacts("AB"))
  end

  test "search using phone number" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, ["(012) 1234-5678"], []]}, {:label => "Create a new contact for '1234'...", :data => [new_contact_path(:contact => {:name => "1234"}), "", [], []]}], ContactSearchHelper.search_for_contacts("1234"))
  end

  test "search using phone number with symbols" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    hash = default_hash(PhoneNumber, :number => "012 1234-5678")
    hash.delete(:contact)
    contact.phone_numbers << PhoneNumber.new(hash)
    contact.save!
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, ["(012) 1234-5678"], []]}, {:label => "Create a new contact for '1234.5678'...", :data => [new_contact_path(:contact => {:name => "1234.5678"}), "", [], []]}], ContactSearchHelper.search_for_contacts("1234.5678"))
  end

  test "search using skype username" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    hash = default_hash(SkypeContact, :username => "johanson.doe")
    hash.delete(:contact)
    contact.skype_contacts << SkypeContact.new(hash)
    contact.save!
    contact.reload
    assert_equal([{:label => "Jane Doe", :data => [contact_path(contact), contact.company.name, ["johanson.doe"], []]}, {:label => "Create a new contact for 'johanson'...", :data => [new_contact_path(:contact => {:name => "johanson"}), "", [], []]}], ContactSearchHelper.search_for_contacts("johanson"))
  end
end
