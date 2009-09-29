class AddCaseStoriesState < ActiveRecord::Migration
  def self.up
    add_column :case_stories, :state, :string
  end

  def self.down
    remove_column :case_stories, :state
  end
end
