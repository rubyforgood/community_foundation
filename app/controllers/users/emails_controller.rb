class Users::EmailsController < ApplicationController
  allow_unauthenticated_access only: :confirm
  rate_limit to: 10, within: 3.minutes, only: :update, with: -> { redirect_to users_email_path, alert: "Try again later." }

  def show
    @user = Current.user
  end

  def update
    @user = Current.user

    if @user.password_set? && !@user.authenticate(params[:current_password].to_s)
      @user.errors.add(:current_password, "is incorrect")
      render :show, status: :unprocessable_entity
      return
    end

    candidate = params.dig(:user, :unconfirmed_email).to_s.strip.downcase

    if error = email_change_error(candidate)
      @user.errors.add(:unconfirmed_email, error)
      render :show, status: :unprocessable_entity
      return
    end

    @user.update!(unconfirmed_email: candidate)
    RegistrationMailer.email_change(@user, Current.organization).deliver_later

    redirect_to users_email_path, notice: "Check #{candidate} for a link to confirm your new email address."
  end

  def confirm
    user = User.find_by_token_for(:email_change, params[:token])

    if user.nil? || user.unconfirmed_email.blank?
      redirect_to new_session_path, alert: "That email confirmation link is invalid or has expired."
      return
    end

    target = user.unconfirmed_email

    already_taken = User.where.not(id: user.id).exists?(email_address: target)
    if already_taken
      user.update!(unconfirmed_email: nil)
      redirect_to new_session_path, alert: "That email address is no longer available."
      return
    end

    user.update!(email_address: target, unconfirmed_email: nil)
    redirect_to new_session_path, notice: "Your email address has been updated. Please sign in."
  rescue ActiveRecord::RecordNotUnique, ActiveRecord::RecordInvalid
    user&.update_columns(unconfirmed_email: nil)
    redirect_to new_session_path, alert: "That email address is no longer available."
  end

  private

  def email_change_error(candidate)
    if !User.valid_email_address?(candidate)
      "is not a valid email address"
    elsif candidate == @user.email_address
      "is the same as your current email address"
    elsif User.where.not(id: @user.id).exists?(email_address: candidate)
      "is already taken"
    end
  end
end
