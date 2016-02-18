class CreateSdgPioneerOthers < ActiveRecord::Migration
  def change
    create_table :sdg_pioneer_others do |t|
      t.string :submitter_name
      t.string :submitter_place_of_work
      t.string :submitter_email
      t.string :nominee_name
      t.string :nominee_email
      t.string :nominee_phone
      t.string :nominee_work_place
      t.string :organization_type
      t.string :submitter_job_title
      t.string :submitter_phone
      t.boolean :accepts_tou, default: false, null: false
      t.string :nominee_title
      t.text :why_nominate
      t.integer :sdg_pioneer_role
    end
  end
end
