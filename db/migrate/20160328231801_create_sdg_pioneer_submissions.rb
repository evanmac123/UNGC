class CreateSdgPioneerSubmissions < ActiveRecord::Migration
  def change
    create_table :sdg_pioneer_submissions do |t|
      t.integer :pioneer_type
      t.text :global_goals_activity
      t.string :matching_sdgs
      t.string :name
      t.string :title
      t.string :email
      t.string :phone
      t.string :organization_name
      t.boolean :organization_name_matched, null: false, default: false
      t.string :country_name
      t.text :reason_for_being
      t.boolean :accepts_tou, null: false, default: false
      t.boolean :is_participant, null: false, default: false
      t.string :website_url

      t.timestamps null: false
    end
  end
end
