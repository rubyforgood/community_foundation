class Public::ScenariosController < ApplicationController
  allow_unauthenticated_access only: :show
  skip_before_action :require_organization_membership, only: :show

  def show
    @scenario = Current.organization.scenarios.find_by!(share_token: params[:token])
  end
end
