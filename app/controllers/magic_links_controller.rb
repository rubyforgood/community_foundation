class MagicLinksController < ApplicationController
  allow_unauthenticated_access only: %i[ new create show ]
  rate_limit to: 10, within: 3.minutes, only: :create, with: -> { redirect_to new_magic_link_path, alert: "Try again later." }

  def new
  end

  def create
    # Honeypot: real users never fill this hidden field, bots do
    if params[:nickname].present?
      redirect_to new_session_path, notice: generic_notice
      return
    end

    user = User.find_by(email_address: params[:email_address])

    # Only send to members of this organization
    if user&.member_of?(Current.organization)
      MagicLinkMailer.sign_in_link(user, Current.organization).deliver_later
    end

    redirect_to new_session_path, notice: generic_notice
  end

  def show
    user = User.find_by_token_for(:magic_link, params[:token])

    if user&.member_of?(Current.organization)
      user.confirm! unless user.confirmed?
      start_new_session_for user
      redirect_to after_authentication_url, notice: "You're signed in."
    else
      redirect_to new_session_path, alert: "Sign-in link is invalid or has expired."
    end
  end

  private

  def generic_notice
    "If an account exists for that email, we've sent a sign-in link."
  end
end
