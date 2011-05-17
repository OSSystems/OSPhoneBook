require File.dirname(__FILE__) + '/../../test_helper'

class CompanySearchHelperTest < ActionView::TestCase
  test "empty search without companies" do
    Company.delete_all
    assert_equal({:data => [], :query => "", :suggestions => []}, CompanySearchHelper.search_for_companies(""))
  end

  # contacts are added to avoid clean-up during the search
  test "empty search with one company" do
    Company.delete_all
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:data => [], :query => "", :suggestions => []}, CompanySearchHelper.search_for_companies(""))
  end

  test "search without companies" do
    Company.delete_all
    assert_equal({:data => [""], :query => "Super", :suggestions => ["Create a new company entry for 'Super'"]}, CompanySearchHelper.search_for_companies("Super"))
  end

  test "search with one company" do
    Company.delete_all
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "Super", :suggestions => ["Super Company", "Create a new company entry for 'Super'"], :data => [company.id, ""]}, CompanySearchHelper.search_for_companies("Super"))
  end

  test "search with blank space" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "  Super", :suggestions => ["Super Company", "Create a new company entry for 'Super'"], :data => [company.id, ""]}, CompanySearchHelper.search_for_companies("  Super"))
  end

  test "search with string from the middle of the name" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "pa", :suggestions => ["Super Company", "Create a new company entry for 'pa'"], :data => [company.id, ""]}, CompanySearchHelper.search_for_companies("pa"))
  end

  test "search with different string case" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "MPA", :suggestions => ["Super Company", "Create a new company entry for 'MPA'"], :data => [company.id, ""]}, CompanySearchHelper.search_for_companies("MPA"))
  end

  test "search with no matching string" do
    company = Company.create!(default_hash(Company))
    Contact.create!(default_hash(Contact, :company => company))
    assert_equal({:query => "Macro", :suggestions => ["Create a new company entry for 'Macro'"], :data => [""]}, CompanySearchHelper.search_for_companies("Macro"))
  end

  test "search with two companies" do
    company1 = Company.create!(default_hash(Company, :name => "Macro Corp"))
    company2 = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company1))
    Contact.create!(default_hash(Contact, :company => company2, :name => "Jane Doe"))
    assert_equal({:query => "Co", :suggestions => ["Macro Corp", "Super Company", "Create a new company entry for 'Co'"], :data => [company1.id, company2.id, ""]}, CompanySearchHelper.search_for_companies("Co"))
  end

  test "search with two companies returning only one" do
    company = Company.create!(default_hash(Company, :name => "Super Company"))
    Contact.create!(default_hash(Contact, :company => company))
    company = Company.create!(default_hash(Company, :name => "Macro Corp"))
    Contact.create!(default_hash(Contact, :company => company, :name => "Jane Doe"))
    assert_equal({:query => "Macro", :suggestions => ["Macro Corp", "Create a new company entry for 'Macro'"], :data => [company.id, ""]}, CompanySearchHelper.search_for_companies("Macro"))
  end
end
