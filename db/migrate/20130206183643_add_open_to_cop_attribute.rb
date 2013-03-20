class AddOpenToCopAttribute < ActiveRecord::Migration
  def self.up
    add_column :cop_attributes, :open, :boolean, :default => false
  end

  def self.down
    remove_column :cop_attributes, :open
  end
end
