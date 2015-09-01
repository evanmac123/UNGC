class AddSustainableDevelopmentGoalsToTaggings < ActiveRecord::Migration
  def change
    add_reference :taggings, :sustainable_development_goal, index: true
    add_foreign_key :taggings, :sustainable_development_goals
  end
end
