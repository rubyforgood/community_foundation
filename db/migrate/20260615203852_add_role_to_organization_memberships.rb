class AddRoleToOrganizationMemberships < ActiveRecord::Migration[8.1]
  def change
    add_column :organization_memberships, :role, :string, null: false, default: "member"
  end
end
