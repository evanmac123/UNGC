class RenameEventsOverviewDescriptionToProgrammeDescription < ActiveRecord::Migration
  def self.up
    rename_column :events, :overview_description, :programme_description
  end

  def self.down
    rename_column :events, :programme_description, :overview_description
  end
end
