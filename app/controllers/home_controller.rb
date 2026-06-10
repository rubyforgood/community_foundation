class HomeController < ApplicationController
  allow_unauthenticated_access only: :show
  allow_without_organization only: :show

  def show
    return if Current.organization

    # Same URL, but the apex (no tenant) lists the community foundations to visit.
    @organizations = Organization.order(:name)
    render :landing
  end
end
