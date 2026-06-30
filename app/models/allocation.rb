class Allocation < ApplicationRecord
  belongs_to :scenario
  belongs_to :allocation_category, optional: true

  has_many :allocation_preferences, dependent: :destroy
  has_many :preference_categories, through: :allocation_preferences, source: :allocation_category

  validate :category_or_option_present

  def display_label
    allocation_category&.name || option
  end

  def greatest_community_need?
    false
  end

  private

  def category_or_option_present
    if allocation_category_id.blank? && option.blank?
      errors.add(:base, "Choose a category or enter a custom option")
    end
  end
end
