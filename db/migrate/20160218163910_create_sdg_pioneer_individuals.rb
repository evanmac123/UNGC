class CreateSdgPioneerIndividuals < ActiveRecord::Migration
  def change
    create_table :sdg_pioneer_individuals do |t|
      t.boolean :is_participant
      t.string :name
      t.string :email
      t.string :phone
      t.text :description_of_individual
      t.text :other_relevant_info
      t.string :organization_name
      t.boolean :accepts_tou, default: false, null: false
      t.string :supporting_link
      t.string :matching_sdgs
      t.string :local_business_nomination_name
      t.boolean :is_nominated
      t.string :nominating_organization
      t.string :title
      t.string :country_name
      t.integer :local_network_status
      t.string :website_url
      t.string :nominating_individual
    end
  end
end
