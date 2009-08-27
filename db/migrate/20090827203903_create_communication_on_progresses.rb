class CreateCommunicationOnProgresses < ActiveRecord::Migration
  def self.up
    create_table :communication_on_progresses do |t|
      t.string :identifier
      t.integer :organization_id
      t.string :title
      t.string :related_document
      t.string :email
      t.integer :start_year
      t.string :facilitator
      t.string :job_title
      t.integer :start_month
      t.integer :end_month
      t.string :url1
      t.string :url2
      t.string :url3
      t.date :added_on
      t.date :modified_on
      t.string :contact_name
      t.integer :end_year
      t.integer :status
      t.boolean :include_ceo_letter
      t.boolean :include_actions
      t.boolean :include_measurement
      t.boolean :use_indicators
      t.integer :cop_score_id
      t.boolean :use_gri
      t.boolean :has_certification
      t.boolean :notable_program

      t.timestamps
    end
  end

  def self.down
    drop_table :communication_on_progresses
  end
end
