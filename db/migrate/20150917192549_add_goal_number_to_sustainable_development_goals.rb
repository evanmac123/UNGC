class AddGoalNumberToSustainableDevelopmentGoals < ActiveRecord::Migration
  def change
    add_column :sustainable_development_goals, :goal_number, :integer, null: false
  end
end
