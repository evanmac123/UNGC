class AddOrganizationsCopState < ActiveRecord::Migration
  def self.up
    add_column :organizations, :cop_state, :string
  end

  def self.down
    remove_column :organizations, :cop_state
  end
end
