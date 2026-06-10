class EmailConfirmationsController < ApplicationController
  allow_unauthenticated_access only: :show

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
