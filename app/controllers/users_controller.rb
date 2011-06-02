class UsersController < ApplicationController
  before_filter :authenticate_user!
  before_filter :get_user, :only => [:show, :edit, :update, :destroy]

  def index
    @users = User.order(:name).all
    flash.now[:notice] = "No users added." if @users.empty?
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      flash[:notice] = "User created."
      redirect_to users_path
    else
      render "new", :status => :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @user.update_with_password params[:user]
      flash[:notice] = "User updated."
      redirect_to users_path
    else
      render "edit", :status => :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      flash[:notice] = "You cannot remove yourself from the system. Please, ask another user to do it."
    else
      @user.destroy
      flash[:notice] = "User deleted."
    end
    redirect_to users_path
  end

  private
  def get_user
    @user = User.find params[:id]
  end
end
