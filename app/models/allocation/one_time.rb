class Allocation::OneTime < Allocation
  validates :amount,
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

    (amount.to_i / total.to_f * 100).round
  end

  private

  def within_total_giving_amount
    return if amount.blank? || scenario&.total_giving_amount.blank?

    others = scenario.one_time_allocations.where.not(id: id).sum(:amount)
    if others + amount > scenario.total_giving_amount
      errors.add(:amount, "would bring one-time giving to #{others + amount}, over the total giving amount of #{scenario.total_giving_amount.to_i}")
    end
  end
end
