class ScenariosController < ApplicationController
  before_action :set_scenario, only: %i[ show update destroy ]

  def index
    @scenarios = scenarios.order(created_at: :desc)
  end

  def show
  end

  def new
    @scenario = scenarios.new
  end

  def create
    @scenario = scenarios.new(scenario_params)
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
    @scenario.destroy
    redirect_to scenarios_path
  end

  private

  def scenarios
    Current.user.scenarios.where(organization: Current.organization)
  end

  def set_scenario
    @scenario = scenarios.find(params[:id])
  end

  def scenario_params
    params.require(:scenario).permit(:name, :total_giving_amount)
  end
end
