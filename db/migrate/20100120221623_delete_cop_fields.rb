class DeleteCopFields < ActiveRecord::Migration
  def self.up
    remove_column :communication_on_progresses, :statement_location
    remove_column :communication_on_progresses, :concrete_human_rights_activities
    remove_column :communication_on_progresses, :concrete_labour_activities
    remove_column :communication_on_progresses, :concrete_environment_activities
    remove_column :communication_on_progresses, :concrete_anti_corruption_activities
  end

  def self.down
    add_column :communication_on_progresses, :statement_location, :string
    add_column :communication_on_progresses, :concrete_human_rights_activities, :boolean
    add_column :communication_on_progresses, :concrete_labour_activities, :boolean
    add_column :communication_on_progresses, :concrete_environment_activities, :boolean
    add_column :communication_on_progresses, :concrete_anti_corruption_activities, :boolean
  end
end
