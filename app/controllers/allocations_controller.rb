class AllocationsController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario

  def create
    allocation = @scenario.allocations.create(allocation_params)
    if allocation.persisted?
      redirect_to scenario_path(@scenario)
    else
      redirect_to scenario_path(@scenario), alert: allocation.errors.full_messages.to_sentence
    end
  end

  def update
    allocation = @scenario.allocations.find(params[:id])
    if allocation.update(allocation_params)
      redirect_to scenario_path(@scenario)
    else
      redirect_to scenario_path(@scenario), alert: allocation.errors.full_messages.to_sentence
    end
  end

  def destroy
    allocation = @scenario.allocations.find(params[:id])
    if allocation.greatest_community_need?
      redirect_to scenario_path(@scenario), alert: "Greatest Community Need can't be removed."
    else
      allocation.destroy
      redirect_to scenario_path(@scenario)
    end
  end

  private

  def set_scenario
    @scenario = accessible_scenarios.find(params[:scenario_id])
  end

  def allocation_params
    params.require(:allocation).permit(:allocation_category_id, :option, :percentage, :amount, :note, :type, preference_category_ids: [])
  end
end
