class Scenarios::TotalGivingAmountsController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario

  def show
  end

  def edit
  end

  def update
    if @scenario.update(total_giving_amount_params)
      render :show
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_scenario
    @scenario = accessible_scenarios.find(params[:scenario_id])
  end

  def total_giving_amount_params
    params.require(:scenario).permit(:total_giving_amount)
  end
end
