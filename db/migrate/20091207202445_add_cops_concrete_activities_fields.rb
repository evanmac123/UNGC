class AddCopsConcreteActivitiesFields < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :concrete_human_rights_activities, :boolean
    add_column :communication_on_progresses, :concrete_labour_activities, :boolean
    add_column :communication_on_progresses, :concrete_environment_activities, :boolean
    add_column :communication_on_progresses, :concrete_anti_corruption_activities, :boolean

    remove_column :communication_on_progresses, :measures_human_rights_outcomes
    remove_column :communication_on_progresses, :measures_labour_outcomes
    remove_column :communication_on_progresses, :measures_environment_outcomes
    remove_column :communication_on_progresses, :measures_anti_corruption_outcomes
  end

  def self.down
    remove_column :communication_on_progresses, :concrete_human_rights_activities
    remove_column :communication_on_progresses, :concrete_labour_activities
    remove_column :communication_on_progresses, :concrete_environment_activities
    remove_column :communication_on_progresses, :concrete_anti_corruption_activities

    add_column :communication_on_progresses, :measures_human_rights_outcomes, :boolean
    add_column :communication_on_progresses, :measures_labour_outcomes, :boolean
    add_column :communication_on_progresses, :measures_environment_outcomes, :boolean
    add_column :communication_on_progresses, :measures_anti_corruption_outcomes, :boolean
  end
end
