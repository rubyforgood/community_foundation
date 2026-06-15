class Users::PasswordsController < ApplicationController
  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    # Users who already have a password must confirm it before changing it.
    # Passwordless users are adding their first password, so none is required.
    if @user.password_set? && !@user.authenticate(params[:current_password].to_s)
      @user.errors.add(:current_password, "is incorrect")
      render :show, status: :unprocessable_entity
      return
    end

    if @user.update(password_params)
      redirect_to users_password_path, notice: "Password saved."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
