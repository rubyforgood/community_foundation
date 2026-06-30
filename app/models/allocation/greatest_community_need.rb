class Allocation::GreatestCommunityNeed < Allocation::Ongoing
  LABEL = "Greatest Community Need".freeze
  DESCRIPTION =
    "Funds go where local nonprofits need them most — trusted to respond to urgent, unmet needs as they arise.".freeze

  after_initialize :apply_defaults

  validate :only_one_per_scenario

  def display_label
    LABEL
  end

  def greatest_community_need?
    true
  end

  private

  def apply_defaults
    self.option ||= LABEL
    self.percentage ||= 0
  end

  def only_one_per_scenario
    return if scenario_id.blank?

    clash = self.class.where(scenario_id: scenario_id).where.not(id: id)
    errors.add(:base, "Greatest Community Need has already been added") if clash.exists?
  end
end
