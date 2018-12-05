require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class TagTest < ActiveSupport::TestCase
  test "create tag" do
    tag = Tag.create(default_hash(Tag))
    assert tag.valid?
    assert_not tag.new_record?
  end

  test "try to create tag without name" do
    tag = Tag.create(:name => nil)
    assert_equal "Name can't be blank", tag.errors.full_messages.join(", ")
  end

  test "try to repeat tag name" do
    tag = Tag.create(default_hash(Tag))
    assert tag.valid?
    assert_not tag.new_record?
    tag = Tag.create(default_hash(Tag, :name => tag.name))
    assert_equal "Name has already been taken", tag.errors.full_messages.join(", ")
  end

  test "tag has contacts accessor" do
    assert_nothing_raised do
      assert Tag.create(default_hash(Tag)).contacts.empty?
    end
  end
end
