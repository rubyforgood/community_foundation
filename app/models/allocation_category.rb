class AllocationCategory < ApplicationRecord
  belongs_to :organization, class_name: "::Organization"
  belongs_to :parent, class_name: "AllocationCategory", optional: true
  has_many :children, class_name: "AllocationCategory", foreign_key: :parent_id, dependent: :destroy
  has_many :allocations, dependent: :nullify

  validates :name, presence: true

  scope :roots, -> { where(parent_id: nil) }

  TAB_CLASSES = %w[ AllocationCategory::Program AllocationCategory::Population AllocationCategory::Organization ].freeze

  def self.tab_label
    name.demodulize.titleize
  end
end
