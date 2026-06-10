class Allocation < ApplicationRecord
  belongs_to :scenario

  validates :option, presence: true
end
