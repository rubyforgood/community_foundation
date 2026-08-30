class AllocationsController < ApplicationController
  include ScenarioScoping

  before_action :set_scenario

  def create
    allocation = @scenario.allocations.create(allocation_params)
    if allocation.persisted?
      redirect_to scenario_path(@scenario)
    else
      render_errors allocation
    end
  end

  def update
    allocation = @scenario.allocations.find(params[:id])
    if allocation.update(allocation_params)
      redirect_to scenario_path(@scenario)
    else
      render_errors allocation
    end
  end

  def destroy
    allocation = @scenario.allocations.find(params[:id])
    # No delete button is rendered for Greatest Community Need; this guards the route.
    return head :forbidden if allocation.greatest_community_need?

    allocation.destroy
    redirect_to scenario_path(@scenario)
  end

  private

  # Errors go back into the form itself: each one comes back attached to the field
  # that produced it. The form only exists inside a top-layer <dialog>, so there is
  # no other surface a message could render on.
  def render_errors(allocation)
    render turbo_stream: turbo_stream.replace(
      helpers.dom_id(allocation, :form),
      partial: "scenarios/allocation_form",
      locals: { allocation: allocation, scenario: @scenario, color: params[:allocation_color].presence }
    ), status: :unprocessable_entity
  end

  def set_scenario
    @scenario = accessible_scenarios.find(params[:scenario_id])
  end

  def allocation_params
    params.require(:allocation).permit(:allocation_category_id, :option, :percentage, :amount, :note, :type, preference_category_ids: [])
  end
end
