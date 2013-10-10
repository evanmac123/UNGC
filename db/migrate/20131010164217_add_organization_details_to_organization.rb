class AddOrganizationDetailsToOrganization < ActiveRecord::Migration
  def change
    add_column :organizations, :organization_detail_id,   :integer
    add_column :organizations, :organization_detail_type, :string
  end
end
