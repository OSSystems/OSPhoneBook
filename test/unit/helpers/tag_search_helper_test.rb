require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class TagSearchHelperTest < ActionView::TestCase
  test "empty search without tags" do
    Tag.delete_all
    assert TagSearchHelper.search_for_tags("").empty?
  end

  # contacts are added to avoid clean-up during the search
  test "empty search with one tag" do
    Tag.delete_all
    tag = Tag.create!(default_hash(Tag))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert TagSearchHelper.search_for_tags("").empty?
  end

  test "search without tags" do
    Tag.delete_all
    assert_equal([{:data => "Super", :label => "Create new tag named 'Super'"}], TagSearchHelper.search_for_tags("Super"))
  end

  test "search with one tag" do
    Tag.delete_all
    tag = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert_equal([{:label => "Super Tag", :data => "Super Tag"}, {:label => "Create new tag named 'Super'", :data => "Super"}], TagSearchHelper.search_for_tags("Super"))
  end

  test "search with blank space" do
    tag = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert_equal([{:label => "Super Tag", :data => "Super Tag"}, {:label => "Create new tag named 'Super'", :data => "Super"}], TagSearchHelper.search_for_tags("  Super"))
  end

  test "search with string from the middle of the name" do
    tag = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert_equal([{:label => "Super Tag", :data => "Super Tag"}, {:label => "Create new tag named 'pe'", :data => "pe"}], TagSearchHelper.search_for_tags("pe"))
  end

  test "search with different string case" do
    tag = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert_equal([{:label => "Super Tag", :data => "Super Tag"}, {:label => "Create new tag named 'PER'", :data => "PER"}], TagSearchHelper.search_for_tags("PER"))
  end

  test "search with no matching string" do
    tag = Tag.create!(default_hash(Tag))
    contact = Contact.create!(default_hash(Contact))
    contact.tags << tag
    assert_equal([{:label => "Create new tag named 'Macro'", :data => "Macro"}], TagSearchHelper.search_for_tags("Macro"))
  end

  test "search with two tags" do
    tag1 = Tag.create!(default_hash(Tag, :name => "Macro Tag"))
    tag2 = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact1 = Contact.create!(default_hash(Contact))
    contact1.tags << tag1
    contact2 = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    contact2.tags << tag2
    assert_equal([{:label => "Macro Tag", :data => "Macro Tag"}, {:label => "Super Tag", :data => "Super Tag"}, {:label => "Create new tag named 'Ta'", :data => "Ta"}], TagSearchHelper.search_for_tags("Ta"))
  end

  test "search with two tags returning only one" do
    tag1 = Tag.create!(default_hash(Tag, :name => "Super Tag"))
    contact1 = Contact.create!(default_hash(Contact))
    contact1.tags << tag1
    tag2 = Tag.create!(default_hash(Tag, :name => "Macro Tag"))
    contact2 = Contact.create!(default_hash(Contact, :name => "Jane Doe"))
    contact2.tags << tag2
    assert_equal([{:label => "Macro Tag", :data => "Macro Tag"}, {:label => "Create new tag named 'Macro'", :data => "Macro"}], TagSearchHelper.search_for_tags("Macro"))
  end
end
