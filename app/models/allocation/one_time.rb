class Allocation::OneTime < Allocation
  validates :amount_cents,
    presence: true,
    numericality: { only_integer: true, greater_than: 0 }
  validate :within_total_giving_amount

  def ongoing?
    false
  end

  def one_time?
    true
  end

  def share_percentage
    total = scenario.one_time_giving_amount
    return 0 if total.zero?

    (amount.cents / total.cents.to_f * 100).round
  end

  # The most this allocation can be set to while staying within the scenario's
  # total giving budget. Returns nil when no budget is set (the server imposes
  # no cap there either). Never drops below the allocation's own amount so
  # pre-existing over-allocated data stays editable. Used by the view helper so
  # the slider cap and the server validator stay in sync.
  def max_amount(scenario = self.scenario)
    remaining = budget_remaining(scenario)
    return if remaining.nil?

    [ remaining, amount.to_i ].max
  end

  private

  def within_total_giving_amount
    return if amount_cents.blank? || scenario&.total_giving_amount_cents.blank?

    others = scenario.one_time_allocations.where.not(id: id).sum(:amount_cents)
    if others + amount_cents > scenario.total_giving_amount_cents
      errors.add(:amount, "would bring one-time giving to #{(others + amount_cents) / 100.0}, over the total giving amount of #{(scenario.total_giving_amount_cents / 100.0).to_i}")
    end
  end

  def budget_remaining(scenario = self.scenario)
    return nil if scenario.blank? || scenario.total_giving_amount.blank?

    others = scenario.one_time_allocations.where.not(id: id).sum(:amount_cents)
    (scenario.total_giving_amount_cents - others) / 100
  end
end
