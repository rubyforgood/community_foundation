class Scenario < ApplicationRecord
  belongs_to :organization
  belongs_to :user
  has_many :allocations, dependent: :destroy
  has_many :ongoing_allocations, class_name: "Allocation::Ongoing"
  has_many :one_time_allocations, class_name: "Allocation::OneTime"

  validates :name, presence: true

  def ongoing_percentage_total
    ongoing_allocations.sum { |allocation| allocation.percentage.to_i }
  end

  def one_time_giving_amount
    one_time_allocations.sum { |allocation| allocation.amount.to_i }
  end

  def ongoing_giving_amount
    total_giving_amount.to_i - one_time_giving_amount
  end
end
