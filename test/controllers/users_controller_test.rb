require File.expand_path(File.dirname(__FILE__) + '/../test_helper')

class UsersControllerTest < ActionController::TestCase
  def setup
    sign_in users(:admin)
  end

  test "index" do
    User.create!(default_hash(User))
    get :index
    assert_response :success
  end

  test "index without users" do
    User.delete_all
    get :index
    assert_redirected_to new_user_session_path
  end

  test "index without sign in" do
    sign_out users(:admin)
    get :index
    assert_redirected_to new_user_session_path
  end

  test "show" do
    user = User.create!(default_hash(User))
    get :show, params: {id: user.id}
    assert_response :success
  end

  test "show with unknown id" do
    assert_nil User.find_by_id 999
    get :show, params: {id: 999}
    assert_response :not_found
  end

  test "show without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    get :show, params: {id: user.id}
    assert_redirected_to new_user_session_path
  end

  test "new" do
    get :new
    assert_response :success
  end

  test "new without sign in" do
    sign_out users(:admin)
    get :new
    assert_redirected_to new_user_session_path
  end

  test "create" do
    assert_difference "User.count", +1 do
      post :create, params: {user: default_hash(User)}
    end
    assert_redirected_to users_path
    assert_equal "User created.", flash[:notice]
  end

  test "create with wrong data" do
    assert_no_difference "User.count" do
      post :create, params: {user: default_hash(User, name: nil)}
    end
    assert_response :unprocessable_entity
  end

  test "create without sign in" do
    sign_out users(:admin)
    assert_no_difference "User.count" do
      post :create, params: {user: default_hash(User)}
    end
    assert_redirected_to new_user_session_path
  end

  test "edit" do
    user = User.create!(default_hash(User))
    get :edit, params: {id: user.id}
    assert_response :success
  end

  test "edit with unknow id" do
    assert_nil User.find_by_id 999
    get :edit, params: {id: 9999}
    assert_response :not_found
  end

  test "edit without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    get :edit, params: {id: user.id}
    assert_redirected_to new_user_session_path
  end

  test "update" do
    user = User.create!(default_hash(User, password: "password", password_confirmation: "password"))
    put :update, params: {id: user.id, user: default_hash(User, name: "Jane Doe")}
    assert_redirected_to users_path
    assert_equal "User updated.", flash[:notice]
    user.reload
    assert user.valid_password? 'password'
  end

  test "update with wrong data" do
    user = User.create!(default_hash(User))
    original_name = user.name
    put :update, params: {id: user.id, user: default_hash(User, name: nil)}
    assert_response :unprocessable_entity
    user.reload
    assert_equal original_name, user.name
  end

  test "update with unknown id" do
    assert_nil User.find_by_id 999
    put :update, params: {id: 999, user: default_hash(User)}
    assert_response :not_found
  end

  test "update without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    put :update, params: {id: user.id, user: default_hash(User, name: "Jane Doe")}
    assert_redirected_to new_user_session_path
  end

  test "destroy" do
    user = User.create!(default_hash(User))
    assert_difference "User.count", -1 do
      delete :destroy, params: {id: user.id}
    end
    assert_redirected_to users_path
    assert_equal "User deleted.", flash[:notice]
    assert_nil User.find_by_id(user.id)
  end

  test "destroy with unknow id" do
    assert_nil User.find_by_id 999
    assert_no_difference "User.count" do
      delete :destroy, params: {id: 9999}
    end
    assert_response :not_found
  end

  test "destroy without sign in" do
    sign_out users(:admin)
    user = User.create!(default_hash(User))
    assert_no_difference "User.count" do
      delete :destroy, params: {id: user.id}
    end
    assert_redirected_to new_user_session_path
  end

  test "try to destroy current_user" do
    assert_no_difference "User.count" do
      delete :destroy, params: {id: users(:admin)}
    end
    assert_redirected_to users_path
    assert_equal "You cannot remove yourself from the system. Please, ask another user to do it.", flash[:notice]
  end

  test "users index route" do
    assert_routing(
      {method: :get, path: '/users'},
      {controller: 'users', action: 'index'}
    )
  end

  test "users new route" do
    assert_routing(
      {method: :get, path: '/users/new'},
      {controller: 'users', action: 'new'}
    )
  end

  test "users create route" do
    assert_routing(
      {method: :post, path: '/users'},
      {controller: 'users', action: 'create'}
    )
  end

  test "users show route" do
    assert_routing(
      {method: :get, path: '/users/1'},
      {controller: 'users', action: 'show', id: '1'}
    )
  end

  test "users edit route" do
    assert_routing(
      {method: :get, path: '/users/1/edit'},
      {controller: 'users', action: 'edit', id: '1'}
    )
  end

  test "users update route" do
    assert_routing(
      {method: :put, path: '/users/1'},
      {controller: 'users', action: 'update', id: '1'}
    )
  end

  test "users destroy route" do
    assert_routing(
      {method: :delete, path: '/users/1'},
      {controller: 'users', action: 'destroy', id: '1'}
    )
  end
end
