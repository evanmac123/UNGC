class CreateSdgPioneerBusinesses < ActiveRecord::Migration
  def change
    create_table :sdg_pioneer_businesses do |t|
      t.string :organization_name
      t.boolean :is_participant
      t.string :contact_person_name
      t.string :contact_person_title
      t.string :contact_person_email
      t.string :contact_person_phone
      t.string :website_url
      t.string :country_name
      t.integer :local_network_status
      t.text :positive_outcomes
      t.string :matching_sdgs
      t.text :other_relevant_info
      t.string :local_business_name
      t.boolean :accepts_tou, default: false, null: false
      t.boolean :is_nominated
      t.string :nominating_organization
      t.string :nominating_individual
      t.boolean :organization_name_matched, default: false, null: false

      t.timestamps null: false
    end
  end
end
