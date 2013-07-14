class AddWelcomePackageToContact < ActiveRecord::Migration
  def self.up
    add_column :contacts, :welcome_package, :boolean
  end

  def self.down
    remove_column :contacts, :welcome_package
  end
end
