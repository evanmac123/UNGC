class AddRevenueToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :revenue, :integer
  end

  def self.down
    remove_column :organizations, :revenue
  end
end
