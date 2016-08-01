class PasswordsController < ApplicationController
  before_filter :authenticate_user!

  def edit
    @user = current_user
  end

  def update
    @user = current_user
    if @user.update_with_password(user_params)
      sign_in(@user, :bypass_sign_in => true)
      redirect_to @user, :notice => "Password updated."
    else
      render :edit, :status => :unprocessable_entity
    end
  end

  def user_params
    params.fetch(:user, {}).permit(:current_password, :password, :password_confirmation)
  end
end
