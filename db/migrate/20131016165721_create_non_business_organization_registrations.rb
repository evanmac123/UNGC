class CreateNonBusinessOrganizationRegistrations < ActiveRecord::Migration
  def change
    create_table :non_business_organization_registrations do |t|
      t.date :date
      t.string :place
      t.string :authority
      t.string :number
      t.text :mission_statement
      t.integer :organization_id
    end
    add_index :non_business_organization_registrations, "organization_id", name: "index_non_business_organization_registrations_on_organization_id"
  end
end
