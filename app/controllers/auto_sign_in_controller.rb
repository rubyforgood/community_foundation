class AutoSignInController < ApplicationController
  allow_unauthenticated_access
  allow_without_organization

  before_action :ensure_development

  def create
    if (user = User.first)
      start_new_session_for user
      redirect_to root_path
    else
      redirect_to new_registration_path, alert: "No users exist yet."
    end
  end

  private

  def ensure_development
    raise ActionController::RoutingError, "Not Found" unless Rails.env.development?
  end
end
