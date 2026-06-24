class Scenarios::NamesController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario

  def show
  end

  def edit
  end

  def update
    if @scenario.update(name_params)
      render :show
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_scenario
    @scenario = accessible_scenarios.find(params[:scenario_id])
  end

  def name_params
    params.require(:scenario).permit(:name)
  end
end
