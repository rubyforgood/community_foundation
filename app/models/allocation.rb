class Allocation < ApplicationRecord
  belongs_to :scenario
  belongs_to :allocation_category, optional: true

  validate :category_or_option_present

  def display_label
    allocation_category&.name || option
  end

  private

  def category_or_option_present
    if allocation_category_id.blank? && option.blank?
      errors.add(:base, "Choose a category or enter a custom option")
    end
  end
end
