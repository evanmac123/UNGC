class RenameCopWebBasedToIsSharedWithStakeholders < ActiveRecord::Migration
  def self.up
    rename_column :communication_on_progresses, :web_based, :is_shared_with_stakeholders
  end

  def self.down
    rename_column :communication_on_progresses, :is_shared_with_stakeholders, :web_based
  end
end