class OrganizationMembership < ApplicationRecord
  belongs_to :user
  belongs_to :organization

  enum :role, { member: "member", admin: "admin", owner: "owner" }, default: :member

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, presence: true
end
