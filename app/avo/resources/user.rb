class Avo::Resources::User < Avo::BaseResource
  self.title = :email_address

  def fields
    field :id, as: :id
    field :email_address, as: :text, readonly: true
    field :name, as: :text, readonly: true

    field :super_admin, as: :boolean

    field :confirmed_at, as: :date_time, readonly: true
    field :created_at, as: :date_time, readonly: true, only_on: :show
    field :updated_at, as: :date_time, readonly: true, only_on: :show

    field :organizations, as: :has_many, through: :organization_memberships
  end
end
