class RemoveApprovedFromEvents < ActiveRecord::Migration
  def self.up
    remove_column :events, :approved
  end

  def self.down
    add_column :events, :approved, :boolean, :default => false
  end
end
