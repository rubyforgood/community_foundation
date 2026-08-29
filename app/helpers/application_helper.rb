module ApplicationHelper
  def owner?
    Current.user&.owner_of?(Current.organization)
  end

  # Format an integer count of cents as whole-dollar currency for display.
  def currency_for_cents(cents)
    cents = cents.to_i
    number_to_currency(cents / 100.0, precision: 0)
  end

  # Format a Money value as whole-dollar currency for display, matching the
  # app's precision-0 convention. Returns nil for a missing amount.
  def money_for_display(money)
    number_to_currency(money&.amount, precision: 0)
  end
end
