class Allocation::Ongoing < Allocation
  PERPETUITY_PAYOUT_RATE = 0.05

  validates :percentage,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validate :within_ongoing_percentage_total

  def dollar_amount
    (percentage.to_i / 100.0 * scenario.ongoing_giving_amount).round
  end

  def perpetuity_annual_amount
    (dollar_amount * PERPETUITY_PAYOUT_RATE).round
  end

  def ongoing?
    true
  end

  def one_time?
    false
  end

  private

  def within_ongoing_percentage_total
    return if percentage.blank? || scenario.blank?

    others = scenario.ongoing_allocations.where.not(id: id).sum(:percentage)
    if others + percentage > 100
      errors.add(:percentage, "would bring ongoing giving to #{others + percentage}%, over 100%")
    end
  end
end
