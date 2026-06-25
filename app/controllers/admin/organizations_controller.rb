class Admin::OrganizationsController < Admin::ApplicationController
  before_action :require_owner

  def edit
    @organization = Current.organization
  end

  def update
    @organization = Current.organization

    if @organization.update(organization_params)
      redirect_to edit_admin_organization_path, notice: "Organization updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def organization_params
    params.require(:organization).permit(:name, :logo)
  end

  def require_owner
    redirect_to root_path, alert: "You don't have access to that." unless
      Current.user.owner_of?(Current.organization)
  end
end
