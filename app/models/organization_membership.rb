class OrganizationMembership < ApplicationRecord
  include UserSearchable

  belongs_to :user
  belongs_to :organization

  enum :role, { member: "member", admin: "admin", owner: "owner" }, default: :member

  validates :user_id, uniqueness: { scope: :organization_id }
  validates :role, presence: true

  def accessible_scenarios
    if admin? || owner?
      organization.scenarios
    else
      owned_scenarios
    end
  end

  def owned_scenarios
    user.scenarios.where(organization: organization)
  end
end
