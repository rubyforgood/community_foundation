module ApplicationHelper
  def owner?
    Current.user&.owner_of?(Current.organization)
  end

  # Format an integer count of cents as whole-dollar currency for display.
  def currency_for_cents(cents)
    cents = cents.to_i
    number_to_currency(cents / 100.0, precision: 0)
  end
end
