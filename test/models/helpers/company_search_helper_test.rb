require File.expand_path(File.dirname(__FILE__) + '/../../test_helper')

class CompanySearchHelperTest < ActionView::TestCase
  test "empty search without companies" do
    Company.delete_all
    assert CompanySearchHelper.search_for_companies("").empty?
  end

  # contacts are added to avoid clean-up during the search
  test "empty search with one company" do
    Company.delete_all
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, :company => company))
    assert CompanySearchHelper.search_for_companies("").empty?
  end

  test "search without companies" do
    Company.delete_all
    assert_equal([{:value => "Super", :label => "Create new company for 'Super'"}], CompanySearchHelper.search_for_companies("Super"))
  end

  test "search with one company" do
    Company.delete_all
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => "Super Company", :value => "Super Company"}, {:label => "Create new company for 'Super'", :value => "Super"}], CompanySearchHelper.search_for_companies("Super"))
  end

  test "search with exact company name returns empty" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert CompanySearchHelper.search_for_companies("").empty?
  end

  test "search with blank space" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => "Super Company", :value => "Super Company"}, {:label => "Create new company for 'Super'", :value => "Super"}], CompanySearchHelper.search_for_companies("  Super"))
  end

  test "search with string from the middle of the name" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => "Super Company", :value => "Super Company"}, {:label => "Create new company for 'pa'", :value => "pa"}], CompanySearchHelper.search_for_companies("pa"))
  end

  test "search with different string case" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => "Super Company", :value => "Super Company"}, {:label => "Create new company for 'MPA'", :value => "MPA"}], CompanySearchHelper.search_for_companies("MPA"))
  end

  test "search with no matching string" do
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal([{:label => "Create new company for 'Macro'", :value => "Macro"}], CompanySearchHelper.search_for_companies("Macro"))
  end

  test "search with two companies" do
    company1 = Company.create!(default_hash(Company, :name => "Macro Corp"))
    company2 = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company1))
    Contact.create!(default_hash(Contact, :company => company2, :name => "Jane Doe"))
    assert_equal([{:label => "Macro Corp", :value => "Macro Corp"}, {:label => "Super Company", :value => "Super Company"}, {:label => "Create new company for 'Co'", :value => "Co"}], CompanySearchHelper.search_for_companies("Co"))
  end

  test "search with two companies returning only one" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    company = Company.create!(default_hash(Company, :name => "Macro Corp"))
    Contact.create!(default_hash(Contact, :company => company, :name => "Jane Doe"))
    assert_equal([{:label => "Macro Corp", :value => "Macro Corp"}, {:label => "Create new company for 'Macro'", :value => "Macro"}], CompanySearchHelper.search_for_companies("Macro"))
  end
end
