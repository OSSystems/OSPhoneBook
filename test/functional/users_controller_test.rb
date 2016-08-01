require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UsersControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "index" do
    user = User.create!(default_hash(User))
    get :index
    assert_response :success
    assert_template "index"
    assert_equal [user, users(:admin)], assigns(:users)
  end

  test "index without users" do
    User.delete_all
    get :index
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "index without sign in" do
    sign_out users(:admin)
    get :index
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "show" do
    user = User.create!(default_hash(User))
    get :show, :id => user.id
    assert_response :success
    assert_template "show"
  end

  test "show with unknown id" do
    assert_nil User.find_by_id 999
    get :show, :id => 999
    assert_response :not_found
    assert_template "404"
  end

  test "show without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    get :show, :id => user.id
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "new" do
    get :new
    assert_response :success
    assert_template "new"
    assert_not assigns(:user).persisted?
  end

  test "new without sign in" do
    sign_out users(:admin)
    get :new
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "create" do
    post :create, :user => default_hash(User)
    assert_redirected_to users_path
    assert assigns(:user).valid?
    assert assigns(:user).persisted?
    assert_equal "User created.", flash[:notice]
  end

  test "create with wrong data" do
    post :create, :user => default_hash(User, :name => nil)
    assert_response :unprocessable_entity
    assert_template "new"
    assert assigns(:user).invalid?
    assert_not assigns(:user).persisted?
  end

  test "create without sign in" do
    sign_out users(:admin)
    post :create, :user => default_hash(User)
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "edit" do
    user = User.create!(default_hash(User))
    get :edit, :id => user.id
    assert_response :success
    assert_template "edit"
    assert_equal user, assigns(:user)
  end

  test "edit with unknow id" do
    assert_nil User.find_by_id 999
    get :edit, :id => 9999
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:user)
  end

  test "edit without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    get :edit, :id => user.id
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "update" do
    user = User.create!(default_hash(User, :password => "password", :password_confirmation => "password"))
    put :update, :id => user.id, :user => default_hash(User, :name => "Jane Doe")
    assert_redirected_to users_path
    assert_equal "User updated.", flash[:notice]
    assert assigns(:user).errors.empty?
    assert_equal user, assigns(:user)
  end

  test "update with wrong data" do
    user = User.create!(default_hash(User))
    put :update, :id => user.id, :user => default_hash(User, :name => nil)
    assert_response :unprocessable_entity
    assert_template "edit"
    assert assigns(:user).invalid?
    assert_equal user, assigns(:user)
  end

  test "update with unknown id" do
    assert_nil User.find_by_id 999
    put :update, :id => 999, :user => default_hash(User)
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:user)
  end

  test "update without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    put :update, :id => user.id, :user => default_hash(User, :name => "Jane Doe")
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "destroy" do
    user = User.create!(default_hash(User))
    delete :destroy, :id => user.id
    assert_redirected_to users_path
    assert_not assigns(:user).persisted?
    assert_equal "User deleted.", flash[:notice]
    assert_nil User.find_by_id(user.id)
  end

  test "destroy with unknow id" do
    assert_nil User.find_by_id 999
    delete :destroy, :id => 9999
    assert_response :not_found
    assert_template "404"
    assert_nil assigns(:user)
  end

  test "destroy without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    delete :destroy, :id => user.id
    assert_redirected_to new_user_session_path
    assert_nil assigns(:users)
  end

  test "try to destroy current_user" do
    delete :destroy, :id => users(:admin)
    assert_redirected_to users_path
    assert_equal "You cannot remove yourself from the system. Please, ask another user to do it.", flash[:notice]
    assert_equal users(:admin), assigns(:user)
    assert assigns(:user).persisted?
  end

  test "users index route" do
    assert_routing(
      {:method => :get, :path => '/users'},
      {:controller => 'users', :action => 'index'}
    )
  end

  test "users new route" do
    assert_routing(
      {:method => :get, :path => '/users/new'},
      {:controller => 'users', :action => 'new'}
    )
  end

  test "users create route" do
    assert_routing(
      {:method => :post, :path => '/users'},
      {:controller => 'users', :action => 'create'}
    )
  end

  test "users show route" do
    assert_routing(
      {:method => :get, :path => '/users/1'},
      {:controller => 'users', :action => 'show', :id => '1'}
    )
  end

  test "users edit route" do
    assert_routing(
      {:method => :get, :path => '/users/1/edit'},
      {:controller => 'users', :action => 'edit', :id => '1'}
    )
  end

  test "users update route" do
    assert_routing(
      {:method => :put, :path => '/users/1'},
      {:controller => 'users', :action => 'update', :id => '1'}
    )
  end

  test "users destroy route" do
    assert_routing(
      {:method => :delete, :path => '/users/1'},
      {:controller => 'users', :action => 'destroy', :id => '1'}
    )
  end
end
