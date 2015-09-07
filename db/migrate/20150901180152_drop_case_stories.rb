class DropCaseStories < ActiveRecord::Migration
  def change
    drop_table :case_stories
  end
end
