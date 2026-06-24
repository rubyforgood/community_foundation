class AllocationsController < ApplicationController
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
    @scenario.allocations.find(params[:id]).destroy
    redirect_to scenario_path(@scenario)
  end

  private

  def set_scenario
    @scenario = Current.user.scenarios.where(organization: Current.organization).find(params[:scenario_id])
  end

  def allocation_params
    params.require(:allocation).permit(:allocation_category_id, :option, :percentage, :amount, :note, :type)
  end
end
