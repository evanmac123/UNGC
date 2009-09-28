class FixCaseStoriesFields < ActiveRecord::Migration
  def self.up
    add_column :case_stories, :is_partnership_project, :boolean
    add_column :case_stories, :is_internalization_project, :boolean
    
    remove_column :case_stories, :case_type
    remove_column :case_stories, :category
  end

  def self.down
    remove_column :case_stories, :is_partnership_project
    remove_column :case_stories, :is_internalization_project

    add_column :case_stories, :case_type, :integer
    add_column :case_stories, :category, :integer
  end
end
