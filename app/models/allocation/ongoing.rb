class Allocation::Ongoing < Allocation
  validates :percentage,
    presence: true,
    numericality: { only_integer: true, greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }

  def ongoing?
    true
  end

  def one_time?
    false
  end
end
