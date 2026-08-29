module MoneyCents
  extend ActiveSupport::Concern

  class_methods do
    # Declares a money column that is stored as an integer count of cents in
    # the database, while exposing the user-facing value in whole dollars.
    #
    #   money_cents :amount
    #
    # expects a db column named `amount_cents` (integer). It adds:
    #   - `amount`        -> dollars (Float), for display and form population
    #   - `amount=`       -> accepts dollars, stores cents
    #   - `amount_cents`  -> raw integer cents (used by internal math)
    def money_cents(*fields)
      fields.each do |field|
        cents_field = "#{field}_cents"

        define_method(field) do
          cents = send(cents_field)
          cents.nil? ? nil : cents / 100.0
        end

        define_method("#{field}=") do |dollars|
          cents = if dollars.blank?
            nil
          else
            (dollars.to_f * 100).round
          end
          send("#{cents_field}=", cents)
        end
      end
    end
  end
end
