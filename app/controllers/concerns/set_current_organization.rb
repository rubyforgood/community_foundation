module SetCurrentOrganization
  extend ActiveSupport::Concern

  included do
    before_action :set_current_organization
    # Every page belongs to a tenant. Runs before authentication so an org-less
    # request is sent home rather than bounced through the sign-in page first.
    before_action :require_organization
  end

  class_methods do
    # Opt out of the tenant requirement (HomeController#show renders the apex landing).
    def allow_without_organization(**options)
      skip_before_action :require_organization, **options
    end
  end

  private

  def set_current_organization
    return if current_subdomain.nil? # apex / www → no tenant

    Current.organization = Organization.find_by(subdomain: current_subdomain)
    raise ActionController::RoutingError, "Organization not found" if Current.organization.nil?
  end

  # nil on the apex (no subdomain) or the reserved "www" host
  def current_subdomain
    subdomain = request.subdomain.presence
    subdomain unless subdomain == "www"
  end

  # Authenticated user browsing an org they don't belong to → bounce to apex, no message.
  # Runs even on allow_unauthenticated_access actions, so resume the session ourselves
  # to learn who (if anyone) is signed in before checking membership.
  def require_organization_membership
    return if Current.organization.nil?

    resume_session
    return if Current.user.nil?

    unless Current.user.member_of?(Current.organization)
      redirect_to root_url(subdomain: false), allow_other_host: true
    end
  end

  # No tenant resolved (apex / no subdomain) → send to the apex home landing.
  def require_organization
    redirect_to root_url(subdomain: false), allow_other_host: true if Current.organization.nil?
  end
end
