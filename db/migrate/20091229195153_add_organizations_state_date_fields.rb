class AddOrganizationsStateDateFields < ActiveRecord::Migration
  def self.up
    add_column :organizations, :rejected_on, :date
    add_column :organizations, :network_review_on, :date
  end

  def self.down
    remove_column :organizations, :rejected_on
    remove_column :organizations, :network_review_on
  end
end
