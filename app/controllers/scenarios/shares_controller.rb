class Scenarios::SharesController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario

  def create
    @scenario.enable_sharing!
    redirect_to scenario_path(@scenario)
  end

  def update
    @scenario.regenerate_share_token!
    redirect_to scenario_path(@scenario)
  end

  def destroy
    @scenario.disable_sharing!
    redirect_to scenario_path(@scenario)
  end

  private

  def set_scenario
    @scenario = accessible_scenarios.find(params[:scenario_id])
  end
end
