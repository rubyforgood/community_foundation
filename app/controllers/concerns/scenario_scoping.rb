module ScenarioScoping
  extend ActiveSupport::Concern

  included do
    helper_method :viewing_on_behalf?
  end

  private

  def accessible_scenarios
    Current.organization_membership&.accessible_scenarios || owned_scenarios
  end

  def owned_scenarios
    Current.user.scenarios.where(organization: Current.organization)
  end

  def viewing_on_behalf?(scenario)
    scenario.present? && scenario.user_id != Current.user.id
  end
end
