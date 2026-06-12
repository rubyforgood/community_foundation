class EmailConfirmationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create show ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_email_confirmation_path, alert: "Try again later." }

  def new
  end

  def create
    user = User.find_by(email_address: params[:email_address])

    if user && !user.confirmed?
      RegistrationMailer.confirmation(user, Current.organization).deliver_later
    end

    redirect_to new_session_path, notice: "Confirmation instructions sent (if an unconfirmed account with that email address exists)."
  end

  def show
    if user = User.find_by_token_for(:email_confirmation, params[:token])
      user.confirm! unless user.confirmed?
      start_new_session_for user
      redirect_to after_authentication_url, notice: "Your email address has been confirmed."
    else
      redirect_to new_session_path, alert: "Email confirmation link is invalid or has expired."
    end
  end
end
