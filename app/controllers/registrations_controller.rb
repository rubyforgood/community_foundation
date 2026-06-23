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
      redirect_to new_session_path, notice: confirmation_notice
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

      if @user.password_set?
        RegistrationMailer.confirmation(@user, Current.organization).deliver_later
        redirect_to new_session_path, notice: confirmation_notice
      else
        # Passwordless signup: send a magic link that confirms and signs them in.
        MagicLinkMailer.sign_in_link(@user, Current.organization).deliver_later
        redirect_to new_session_path, notice: "Check your email for a sign-in link."
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def confirmation_notice
    "Check your email to confirm your account before signing in."
  end

  def registration_params
    params.require(:user).permit(:name, :email_address, :password, :password_confirmation)
  end
end
