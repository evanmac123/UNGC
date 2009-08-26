class CreateOrganizations < ActiveRecord::Migration
  def self.up
    create_table :organizations do |t|
      t.integer :old_id
      t.string :name
      t.integer :organization_type_id
      t.integer :sector_id
      t.boolean :local_network
      t.boolean :participant
      t.integer :employees
      t.string :url

      t.timestamps
    end
  end

  def self.down
    drop_table :organizations
  end
end
