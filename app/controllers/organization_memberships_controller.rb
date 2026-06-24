class OrganizationMembershipsController < ApplicationController
  PER_PAGE = 50

  before_action :require_member_management
  before_action :set_membership, only: :update

  def index
    @query = params[:q].to_s.strip
    @roles = Array(params[:roles]).select { |role| OrganizationMembership.roles.key?(role) }
    @page = [ params[:page].to_i, 1 ].max
    @offset = (@page - 1) * PER_PAGE

    scope = Current.organization.organization_memberships.search_by_user(@query)
    scope = scope.where(role: @roles) if @roles.any?
    @total = scope.count
    @has_more = @offset + PER_PAGE < @total
    @memberships = scope.limit(PER_PAGE).offset(@offset)
  end

  def update
    OrganizationMembership::RoleUpdater.new(@membership, actor: Current.user, role: params[:role]).call
    redirect_to organization_memberships_path(q: params[:q], roles: params[:roles], page: params[:page])
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
