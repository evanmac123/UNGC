class AddParentCompanyIdToOrganizations < ActiveRecord::Migration
  def change
    add_column :organizations, :parent_company_id, :integer, index: true, foreign_key: true
  end
end
