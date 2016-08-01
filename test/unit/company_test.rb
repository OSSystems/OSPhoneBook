require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class CompanyTest < ActiveSupport::TestCase
  test "create company" do
    company = Company.create(default_hash(Company))
    assert company.valid?
    assert_not company.new_record?
  end

  test "try to create company without name" do
    company = Company.create(:name => nil)
    assert_equal "Name can't be blank", company.errors.full_messages.join(", ")
  end

  test "try to repeat company name" do
    company = Company.create(default_hash(Company))
    assert company.valid?
    assert_not company.new_record?
    company = Company.create(default_hash(Company))
    assert_equal "Name has already been taken", company.errors.full_messages.join(", ")
  end

  test "company has contacts accessor" do
    assert_nothing_raised do
      assert Company.create(default_hash(Company)).contacts.empty?
    end
  end
end
