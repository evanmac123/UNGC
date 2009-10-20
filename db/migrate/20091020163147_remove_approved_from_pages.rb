class RemoveApprovedFromPages < ActiveRecord::Migration
  def self.up
    remove_column :pages, :approved
  end

  def self.down
    add_column :pages, :approved, :boolean, :default => false
  end
end
