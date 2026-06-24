class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :organization
  delegate :user, to: :session, allow_nil: true

  def organization_membership
    user&.membership_in(organization)
  end
end
