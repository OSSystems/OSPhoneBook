require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class PasswordsControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "edit" do
    get :edit
    assert_response :success
  end

  test "edit without sign in" do
    sign_out users(:admin)
    get :edit
    assert_redirected_to new_user_session_path
  end

  test "update" do
    put :update, params: {user: {current_password: "admin1", password: "super password", password_confirmation: "super password"}}
    assert_redirected_to users(:admin)
    user = users(:admin)
    user.reload
    assert user.valid_password?("super password")
  end

  test "update with wrong password" do
    put :update, params: {user: {current_password: "wrongpassword", password: "super password", password_confirmation: "super password"}}
    assert_response :unprocessable_entity
    user = users(:admin)
    user.reload
    assert user.valid_password?("admin1")
  end

  test "update with different password confirmation" do
    put :update, params: {user: {current_password: "admin1", password: "super password", password_confirmation: "password super"}}
    assert_response :unprocessable_entity
    user = users(:admin)
    user.reload
    assert user.valid_password?("admin1")
  end

  test "update without sign in" do
    sign_out users(:admin)
    put :update, params: {user: {current_password: "admin1", password: "super password", password_confirmation: "super password"}}
    assert_redirected_to new_user_session_path
    user = users(:admin)
    user.reload
    assert user.valid_password?("admin1")
  end

  test "edit route" do
    assert_routing(
      {method: :get, path: '/user/change_password'},
      {controller: 'passwords', action: 'edit'}
    )
  end

  test "update route" do
    assert_routing(
      {method: :put, path: '/user/change_password'},
      {controller: 'passwords', action: 'update'}
    )
  end
end
