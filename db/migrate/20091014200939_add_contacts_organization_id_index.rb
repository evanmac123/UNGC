class AddContactsOrganizationIdIndex < ActiveRecord::Migration
  def self.up
    add_index :contacts, :organization_id
  end

  def self.down
    remove_index :contacts, :organization_id
  end
end
