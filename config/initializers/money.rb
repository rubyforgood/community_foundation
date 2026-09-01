# encoding : utf-8

MoneyRails.configure do |config|
  # Monetary amounts in this app are always USD, stored as integer cents in
  # `_cents` columns.
  config.default_currency = :usd

  # Use whole-dollar formatting (no cents) for display in views.
  config.no_cents_if_whole = true
end

# Make `number_to_currency` delegate to the money gem whenever it receives a
# Money object, so display formatting (currency, no_cents_if_whole) is handled
# by Money instead of Rails' numeric formatter.
module MoneyNumberToCurrency
  def number_to_currency(number, options = {})
    return number.format(options) if number.is_a?(Money)

    super
  end
end
ActionView::Helpers::NumberHelper.prepend(MoneyNumberToCurrency)
