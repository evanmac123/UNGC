class CreateCaseStories < ActiveRecord::Migration
  def self.up
    create_table :case_stories do |t|
      t.string :identifier
      t.integer :organization_id
      t.string :title
      t.integer :case_type
      t.integer :category
      t.date :case_date
      t.string :description
      t.string :url1
      t.string :url2
      t.string :url3
      t.string :author1
      t.string :author1_institution
      t.string :author1_email
      t.string :author2
      t.string :author2_institution
      t.string :author2_email
      t.string :reviewer1
      t.string :reviewer1_institution
      t.string :reviewer1_email
      t.string :reviewer2
      t.string :reviewer2_institution
      t.string :reviewer2_email
      t.boolean :uploaded
      t.string :contact1
      t.string :contact1_email
      t.string :contact2
      t.string :contact2_email
      t.integer :status
      t.string :extension

      t.timestamps
    end
  end

  def self.down
    drop_table :case_stories
  end
end
