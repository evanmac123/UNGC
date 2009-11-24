class AddRolesInitiativeId < ActiveRecord::Migration
  def self.up
    add_column :roles, :initiative_id, :integer
  end

  def self.down
    remove_column :roles, :initiative_id
  end
end
