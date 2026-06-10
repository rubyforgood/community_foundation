class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_registration_path, alert: "Try again later." }

  def new
    @user = User.new
  end

  def create
    # Honeypot: real users never fill this hidden field, bots do. Silently
    # pretend success so spammers can't tell their submission was rejected.
    if params[:nickname].present?
      redirect_to new_session_path, notice: "Check your email to confirm your account before signing in."
      return
    end

    @user = User.new(registration_params)

    # Emails are globally unique. An existing account (member of this org or not)
    # is sent to sign in rather than shown a uniqueness error.
    if User.exists?(email_address: @user.email_address)
      redirect_to new_session_path, notice: "You already have an account. Please sign in."
      return
    end

    if @user.valid?
      ActiveRecord::Base.transaction do
        @user.save!
        Current.organization.organization_memberships.create!(user: @user)
      end

      RegistrationMailer.confirmation(@user, Current.organization).deliver_later
      redirect_to new_session_path, notice: "Check your email to confirm your account before signing in."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def registration_params
    params.require(:user).permit(:email_address, :password, :password_confirmation)
  end
end
