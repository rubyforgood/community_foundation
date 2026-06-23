class Admin::ApplicationController < ApplicationController
  before_action :require_admin

  private

  def require_admin
    redirect_to root_path, alert: "You don't have access to that." unless
      Current.user.admin_of?(Current.organization)
  end
end
