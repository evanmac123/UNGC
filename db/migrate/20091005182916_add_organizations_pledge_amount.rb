class AddOrganizationsPledgeAmount < ActiveRecord::Migration
  def self.up
    add_column :organizations, :pledge_amount, :integer
  end

  def self.down
    remove_column :organizations, :pledge_amount
  end
end
