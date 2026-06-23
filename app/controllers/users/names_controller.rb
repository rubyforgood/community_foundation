class Users::NamesController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.update(name_params)
      redirect_to users_name_path, notice: "Name saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def name_params
    params.require(:user).permit(:name)
  end
end
