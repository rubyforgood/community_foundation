class Allocation::OneTime < Allocation
  # allow_nil hands the blank case to the presence validator alone, so a blank
  # field yields one message instead of two.
  validates :amount,
    presence: { message: "Enter an amount." },
    numericality: {
      only_integer: true, greater_than: 0, allow_nil: true,
      message: "Enter a whole dollar amount greater than $0."
    }
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
    return if errors[:amount].any?

    total = scenario.total_giving_amount.to_i
    others = scenario.one_time_allocations.where.not(id: id).sum(:amount)
    return if others + amount <= total

    remaining = [ total - others, 0 ].max
    errors.add(:amount, "You have #{money(remaining)} left to allocate.")
  end

  def money(value)
    ActiveSupport::NumberHelper.number_to_currency(value, precision: 0)
  end
end
