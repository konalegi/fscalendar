class UsersController < ApplicationController
  before_action :authenticate_user!
  before_filter :set_user

  def edit
  end

  def update
    if @user.update(event_params)
      render :edit, notice: 'User was successfully updated.'
    else
      render :edit
    end
  end

  def show
  end

  private
    def set_user
      @user = current_user
    end

    def event_params
      params.require(:user).permit(:full_name, :password, :password_confirmation)
    end

end