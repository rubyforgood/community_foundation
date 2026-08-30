class Allocation::Ongoing < Allocation
  PERPETUITY_PAYOUT_RATE = 0.05

  # allow_nil hands the blank case to the presence validator alone, so a blank
  # field yields one message instead of two.
  validates :percentage,
    presence: { message: "Choose a percentage." },
    numericality: {
      only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100,
      allow_nil: true,
      message: "Enter a percentage between 0 and 100."
    }
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
    return if errors[:percentage].any?

    others = scenario.ongoing_allocations.where.not(id: id).sum(:percentage)
    return if others + percentage <= 100

    remaining = [ 100 - others, 0 ].max
    errors.add(:percentage, "You have #{remaining}% left to allocate.")
  end
end
