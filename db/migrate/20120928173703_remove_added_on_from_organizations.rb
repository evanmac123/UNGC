class RemoveAddedOnFromOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :organizations, :added_on
    remove_column :organizations, :modified_on
  end

  def self.down
    add_column :organizations, :modified_on, :date
    add_column :organizations, :added_on, :date,
  end
end
