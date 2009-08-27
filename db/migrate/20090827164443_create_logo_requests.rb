class CreateLogoRequests < ActiveRecord::Migration
  def self.up
    create_table :logo_requests do |t|
      t.integer :old_id
      t.date :requested_on
      t.date :status_changed_on
      t.integer :publication_id
      t.integer :organization_id
      t.integer :contact_id
      t.integer :reviewer_id
      t.boolean :replied_to
      t.string :purpose
      t.string :status
      t.boolean :accepted
      t.date :accepted_on

      t.timestamps
    end
  end

  def self.down
    drop_table :logo_requests
  end
end
