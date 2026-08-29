# encoding : utf-8

MoneyRails.configure do |config|
  # Monetary amounts in this app are always USD, stored as integer cents in
  # `_cents` columns.
  config.default_currency = :usd

  # Use whole-dollar formatting (no cents) for display in views.
  config.no_cents_if_whole = true
end
