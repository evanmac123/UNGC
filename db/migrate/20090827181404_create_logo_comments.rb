class CreateLogoComments < ActiveRecord::Migration
  def self.up
    create_table :logo_comments do |t|
      t.date :added_on
      t.integer :old_id
      t.integer :logo_request_id
      t.integer :contact_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :logo_comments
  end
end
