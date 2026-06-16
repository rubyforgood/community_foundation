class OrganizationMembershipsController < ApplicationController
  before_action :require_member_management
  before_action :set_membership, only: :update

  def index
    @memberships = Current.organization.organization_memberships
                          .includes(:user).order(:created_at)
  end

  def update
    OrganizationMembership::RoleUpdater.new(@membership, actor: Current.user, role: params[:role]).call
    redirect_to organization_memberships_path
  end

  private

  def set_membership
    @membership = Current.organization.organization_memberships.find(params[:id])
  end

  def require_member_management
    redirect_to root_path, alert: "You don't have access to that." unless
      Current.user.admin_of?(Current.organization)
  end
end
