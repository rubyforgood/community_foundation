class ApplicationController < ActionController::Base
  include SetCurrentOrganization # resolves Current.organization first
  include Authentication # then resumes the session / Current.user

  # Runs after authentication so Current.user is known: keep non-members out of tenants.
  before_action :require_organization_membership

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes
end
