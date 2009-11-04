class ChangeCaseStoryDescriptionToText < ActiveRecord::Migration
  def self.up
    remove_column :case_stories, :description
    # CaseStory.reset_column_information
    add_column :case_stories, :description, :text
  end

  def self.down
    remove_column :case_stories, :description
    add_column :case_stories, :description, :string
  end
end
