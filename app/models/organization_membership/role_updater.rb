class OrganizationMembership::RoleUpdater
  ASSIGNABLE_ROLES = %w[ admin member ].freeze

  Result = Data.define(:status) do
    def updated? = status == :updated
    def forbidden? = status == :forbidden
    def rejected? = status == :rejected
    def success? = updated?
  end

  def initialize(membership, actor:, role:)
    @membership = membership
    @actor = actor
    @role = role
  end

  def call
    return Result.new(:rejected) if @membership.owner? || ASSIGNABLE_ROLES.exclude?(@role)
    return Result.new(:forbidden) if demotion? && !actor_owner?

    @membership.update(role: @role)
    Result.new(:updated)
  end

  private

  def demotion?
    @role == "member"
  end

  def actor_owner?
    @actor.owner_of?(@membership.organization)
  end
end
