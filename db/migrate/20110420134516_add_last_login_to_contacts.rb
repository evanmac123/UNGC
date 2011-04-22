class AddLastLoginToContacts < ActiveRecord::Migration
  def self.up
    add_column :contacts, :last_login_at, :datetime
  end

  def self.down
    remove_column :contacts, :last_login_at
  end
end
