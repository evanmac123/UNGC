class MysqlFixesAnsi < ActiveRecord::Migration
  def up
    change_column :authors_resources, :created_at, :datetime, null: true
    change_column :authors_resources, :updated_at, :datetime, null: true

    change_column :principles_resources, :created_at, :datetime, null: true
    change_column :principles_resources, :updated_at, :datetime, null: true

    Organization.where("inactive_on ='0000-00-00'").update_all(inactive_on: nil)

    rename_index :non_business_organization_registrations,
                 "index_non_business_organization_registrations_on_organization_id",
                 "index_non_business_org_registrations_on_org_id"

    add_index :initiatives, :name, unique: true, name: :unique_index_initiatives_on_name
  end

  def down
    rename_index :non_business_organization_registrations,
                 "index_non_business_org_registrations_on_org_id",
                 "index_non_business_organization_registrations_on_organization_id"

    remove_index :initiatives, name: :unique_index_initiatives_on_name
  end
end
