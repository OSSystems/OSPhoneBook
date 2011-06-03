require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UsersTest < ActiveSupport::TestCase
  test "create user" do
    user = User.create(default_hash(User))
    assert user.valid?, user.errors.full_messages.join(", ")
    assert user.persisted?
  end

  test "try to create user without name" do
    user = User.create(default_hash(User, :name => nil))
    assert_equal "Name can't be blank", user.errors.full_messages.join("\n")
  end

  test "try to create user without e-mail" do
    user = User.create(default_hash(User, :email => nil))
    assert_equal "Email can't be blank", user.errors.full_messages.join("\n")
  end

  test "create user without extension" do
    user = User.create(default_hash(User, :extension => nil))
    assert user.valid?, user.errors.full_messages.join(", ")
    assert user.persisted?
  end

  test "create user without password" do
    hash = default_hash(User, :password => nil)
    hash.delete :password
    hash.delete :password_confirmation
    user = User.create hash
    assert user.valid?, user.errors.full_messages.join(", ")
    assert user.persisted?
  end

  test "attempt_set_password" do
    user = User.create!(default_hash User)
    assert !user.valid_password?("super password")
    user.attempt_set_password(:password => "super password",
                              :password_confirmation => "super password")
    assert user.valid?
    user.reload
    assert user.valid_password?("super password")
  end

  test "attempt_set_password with nil" do
    user = User.create!(default_hash User, {:name => "John Doe",
                          :email => "doe@example.org"})
    user.update_attributes({:password => "super_password", :password_confirmation => "super_password"})
    assert user.valid_password?("super_password")
    user.attempt_set_password nil
    assert user.valid?
    user.reload
    assert user.valid_password?("super_password")
    assert_equal "John Doe", user.name
    assert_equal "doe@example.org", user.email
  end

  test "attempt_set_password with more data" do
    user = User.create!(default_hash User, {:name => "John Doe",
                          :email => "doe@example.org"})
    assert !user.valid_password?("super password")
    user.attempt_set_password(:password => "super password",
                              :password_confirmation => "super password",
                              :name => "this name",
                              :email => "email@example.org")
    assert user.valid?
    user.reload
    assert user.valid_password?("super password")
    assert_equal "John Doe", user.name
    assert_equal "doe@example.org", user.email
  end

  test "attempt_set_password with wrong password" do
    user = User.create!(default_hash User)
    assert !user.valid_password?("super password")
    user.attempt_set_password(:password => "super password",
                              :password_confirmation => "bad password")
    assert user.invalid?
    user.reload
    assert !user.valid_password?("super password")
    assert !user.valid_password?("bad password")
  end

  test "has_no_password" do
    user = User.create!(default_hash User)
    assert user.has_no_password?
    user.attempt_set_password(:password => "super password",
                              :password_confirmation => "super password")
    user.reload
    assert !user.has_no_password?
  end

  test "only_if_unconfirmed" do
    user = User.create!(default_hash User)
    user.only_if_unconfirmed{true} # Success! OK, proceding...
    user.confirm!
    user.reload
    user.only_if_unconfirmed{fail "This shoudn't be running..."}
  end
end
