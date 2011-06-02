require File.dirname(__FILE__) + "/../test_helper"

class ConfirmationsControllerTest < ActionController::TestCase
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  test "show" do
    user = User.create! default_hash(User)
    get :show, :confirmation_token => user.confirmation_token
    assert_response :success
    assert_template "show"
    assert_equal user, assigns(:confirmable)
  end

  test "show without confirmation token" do
    user = User.create! default_hash(User)
    get :show
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:confirmable)
  end

  test "show with confirmed user" do
    user = User.create! default_hash(User)
    user.confirm!
    get :show, :confirmation_token => user.confirmation_token
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:confirmable)
  end

  test "show for unconfirmed user with password set" do
    user = User.create! default_hash(User)
    user.attempt_set_password({:password => "mega password", :password_confirmation => "mega password"})
    get :show, :confirmation_token => user.confirmation_token
    assert_redirected_to root_path
    assert_equal user, assigns(:confirmable)
    user.reload
    assert user.confirmed?
    assert user.valid_password?("mega password")
  end

  test "update" do
    user = User.create! default_hash(User)
    put :update, :confirmation_token => user.confirmation_token, :user => {:password => "mega password", :password_confirmation => "mega password"}
    assert_redirected_to root_path
    assert_equal "Your account was successfully confirmed. You are now signed in.", flash[:notice]
    assert_equal user, assigns(:confirmable)
    assert assigns(:confirmable).valid?
    user.reload
    assert user.confirmed?
    assert user.valid_password?("mega password")
  end

  test "update without confirmation token" do
    user = User.create! default_hash(User)
    put :update
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:confirmable)
  end

  test "update with confirmed user" do
    user = User.create! default_hash(User)
    user.confirm!
    put :update, :confirmation_token => user.confirmation_token
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:confirmable)
  end

  test "update without password" do
    user = User.create! default_hash(User)
    put :update, :confirmation_token => user.confirmation_token
    assert_response :success
    assert_template "show"
    assert_equal user, assigns(:confirmable)
    user.reload
    assert !user.confirmed?
    assert user.has_no_password?
  end

  test "update route" do
    assert_routing(
      {:method => :put, :path => "/user/confirmation"},
      {:controller => "confirmations", :action => "update"}
    )
  end
end
