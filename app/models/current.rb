class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :organization
  delegate :user, to: :session, allow_nil: true
end
