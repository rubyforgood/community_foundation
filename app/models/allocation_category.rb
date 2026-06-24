class AllocationCategory < ApplicationRecord
  belongs_to :organization, class_name: "::Organization"
  belongs_to :parent, class_name: "AllocationCategory", optional: true
  has_many :children, class_name: "AllocationCategory", foreign_key: :parent_id, dependent: :destroy
  has_many :allocations, dependent: :nullify

  validates :name, presence: true
  validates :type, inclusion: { in: ->(_) { TAB_CLASSES } }
  validate :parent_matches_organization_and_type

  scope :roots, -> { where(parent_id: nil) }

  TAB_CLASSES = %w[ AllocationCategory::Program AllocationCategory::Population AllocationCategory::Organization ].freeze

  def self.tab_label
    name.demodulize.titleize
  end

  private

  def parent_matches_organization_and_type
    return if parent.nil?

    errors.add(:parent, "must belong to the same organization") if parent.organization_id != organization_id
    errors.add(:parent, "must be the same type") if parent.type != type
  end
end
