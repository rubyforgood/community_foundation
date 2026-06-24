class Allocation::Ongoing < Allocation
  validates :percentage,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def dollar_amount
    (percentage.to_i / 100.0 * scenario.ongoing_giving_amount).round
  end

  def ongoing?
    true
  end

  def one_time?
    false
  end
end
