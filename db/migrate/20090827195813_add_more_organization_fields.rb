class AddMoreOrganizationFields < ActiveRecord::Migration
  def self.up
    add_column :organizations, :added_on, :date
    add_column :organizations, :modified_on, :date
    add_column :organizations, :joined_on, :date
    add_column :organizations, :delisted_on, :date
    add_column :organizations, :active, :boolean
    add_column :organizations, :country_id, :integer
    add_column :organizations, :stock_symbol, :string
    add_column :organizations, :removal_reason_id, :integer
    add_column :organizations, :last_modified_by_id, :integer
  end

  def self.down
    remove_column :organizations, :last_modified_by_id
    remove_column :organizations, :removal_reason_id
    remove_column :organizations, :stock_symbol
    remove_column :organizations, :country_id
    remove_column :organizations, :active
    remove_column :organizations, :delisted_on
    remove_column :organizations, :joined_on
    remove_column :organizations, :modified_on
    remove_column :organizations, :added_on
  end
end