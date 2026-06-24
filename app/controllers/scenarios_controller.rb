class ScenariosController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario, only: %i[ show update destroy ]

  def index
    @scenarios = owned_scenarios.order(created_at: :desc)
  end

  def show
  end

  def new
    @scenario = owned_scenarios.new
  end

  def create
    @scenario = owned_scenarios.new(scenario_params)
    if @scenario.save
      redirect_to scenario_path(@scenario)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @scenario.update(scenario_params)
      redirect_to scenario_path(@scenario)
    else
      render :show, status: :unprocessable_entity
    end
  end

  def destroy
    on_behalf = viewing_on_behalf?(@scenario)
    @scenario.destroy
    redirect_to on_behalf ? admin_scenarios_path : scenarios_path
  end

  private

  def set_scenario
    @scenario = accessible_scenarios.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(:name, :total_giving_amount)
  end
end
