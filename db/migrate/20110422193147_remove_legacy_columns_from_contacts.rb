class RemoveLegacyColumnsFromContacts < ActiveRecord::Migration
  def self.up
    remove_column :contacts, :ceo
    remove_column :contacts, :contact_point
    remove_column :contacts, :newsletter
    remove_column :contacts, :advisory_council
  end

  def self.down
    add_column :contacts, :ceo, :boolean, :default => false
    add_column :contacts, :contact_point, :boolean, :default => false
    add_column :contacts, :newsletter, :boolean, :default => false
    add_column :contacts, :advisory_council, :boolean, :default => false
  end
end
