class CreateNonBusinessOrganizationDetails < ActiveRecord::Migration
  def change
    create_table :non_business_organization_details do |t|
      t.date :registration_date
      t.string  :registration_place
      t.string  :registration_authority
      t.string  :registration_number
      t.text    :mission_statement
    end
  end
end
