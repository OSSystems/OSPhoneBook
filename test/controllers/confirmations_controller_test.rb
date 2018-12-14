require File.expand_path(File.dirname(__FILE__) + "/../test_helper")

class ConfirmationsControllerTest < ActionController::TestCase
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "show" do
    user = User.create! default_hash(User)
    get :show, params: {confirmation_token: user.confirmation_token}
    assert_response :success
  end

  test "show without confirmation token" do
    User.create! default_hash(User)
    get :show
    assert_response :not_found
  end

  test "show with confirmed user" do
    user = User.create! default_hash(User)
    user.confirm
    get :show, params: {confirmation_token: user.confirmation_token}
    assert_response :not_found
  end

  test "show for unconfirmed user with password set" do
    user = User.create! default_hash(User)
    user.attempt_set_password({password: "mega password", password_confirmation: "mega password"})
    get :show, params: {confirmation_token: user.confirmation_token}
    assert_redirected_to root_path
    user.reload
    assert user.confirmed?
    assert user.valid_password?("mega password")
  end

  test "update" do
    user = User.create! default_hash(User)
    put :update, params: {confirmation_token: user.confirmation_token, user: {password: "mega password", password_confirmation: "mega password"}}
    assert_redirected_to root_path
    assert_equal "Your account was successfully confirmed. You are now signed in.", flash[:notice]
    user.reload
    assert user.confirmed?
    assert user.valid_password?("mega password")
  end

  test "update without confirmation token" do
    user = User.create! default_hash(User)
    put :update
    assert_response :not_found
    user.reload
    assert !user.confirmed?
    assert user.has_no_password?
  end

  test "update with confirmed user" do
    user = User.create! default_hash(User)
    user.confirm
    put :update, params: {confirmation_token: user.confirmation_token}
    assert_response :not_found
    assert user.confirmed?
    assert user.has_no_password?
  end

  test "update without password" do
    user = User.create! default_hash(User)
    put :update, params: {confirmation_token: user.confirmation_token}
    assert_response :success
    user.reload
    assert_not user.confirmed?
    assert user.has_no_password?
  end

  test "update route" do
    assert_routing(
      {method: :put, path: "/user/confirmation"},
      {controller: "confirmations", action: "update"}
    )
  end
end
