require File.dirname(__FILE__) + '/../../test_helper'

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
    assert_equal({:data => [], :query => "John", :suggestions => []}, ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with one contact" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "John", :suggestions => ["John Doe"], :data => [[contact.id, "Placebo S.A", []]]}, ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with blank space" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "  John", :suggestions => ["John Doe"], :data => [[contact.id, "Placebo S.A", []]]}, ContactSearchHelper.search_for_contacts("  John"))
  end

  test "search with one contact with company" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "John", :suggestions => ["John Doe"], :data => [[contact.id, "Placebo S.A", []]]}, ContactSearchHelper.search_for_contacts("John"))
  end

  test "search with string from the middle of the name" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "oh", :suggestions => ["John Doe"], :data => [[contact.id, "Placebo S.A", []]]}, ContactSearchHelper.search_for_contacts("oh"))
  end

  test "search with different string case" do
    contact = Contact.create!(default_hash(Contact))
    assert_equal({:query => "DOE", :suggestions => ["John Doe"], :data => [[contact.id, "Placebo S.A", []]]}, ContactSearchHelper.search_for_contacts("DOE"))
  end

  test "search with two contacts" do
    contact1 = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    contact2 = Contact.create!(default_hash(Contact, :name => "John Doe"))
    assert_equal({:query => "Doe", :suggestions => ["Jane Doe", "John Doe"], :data => [[1, "Placebo S.A", []], [2, "", []]]}, ContactSearchHelper.search_for_contacts("Doe"))
  end

  test "search with two contacts returning only one" do
    Contact.create!(default_hash(Contact, :name => "John Doe"))
    contact = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    assert_equal({:query => "Jane", :suggestions => ["Jane Doe"], :data => [[2, "", []]]}, ContactSearchHelper.search_for_contacts("Jane"))
  end

  test "search using tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.save!
    contact.reload
    assert_equal({:query => "Abnormals", :suggestions => ["Jane Doe"], :data => [[contact.id, "Placebo S.A", ["Abnormals"]]]}, ContactSearchHelper.search_for_contacts("Abnormals"))
  end

  test "search using two tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "Ab", :suggestions => ["Jane Doe"], :data => [[contact.id, "Placebo S.A", ["Abnormals", "Absents"]]]}, ContactSearchHelper.search_for_contacts("Ab"))
  end

  test "search matching name and tags" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "a", :suggestions => ["Jane Doe"], :data => [[contact.id, "Placebo S.A", ["Abnormals", "Absents"]]]}, ContactSearchHelper.search_for_contacts("a"))
  end

  test "search with different string case for tag" do
    contact = Contact.new(default_hash(Contact, :name => "Jane Doe"))
    contact.tags << Tag.new(default_hash(Tag))
    contact.tags << Tag.new(default_hash(Tag, :name => "Absents"))
    contact.save!
    contact.reload
    assert_equal({:query => "AB", :suggestions => ["Jane Doe"], :data => [[contact.id, "Placebo S.A", ["Abnormals", "Absents"]]]}, ContactSearchHelper.search_for_contacts("AB"))
  end
end
