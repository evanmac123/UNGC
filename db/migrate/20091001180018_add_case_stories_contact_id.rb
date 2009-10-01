class AddCaseStoriesContactId < ActiveRecord::Migration
  def self.up
    add_column :case_stories, :contact_id, :integer
  end

  def self.down
    remove_column :case_stories, :contact_id
  end
end
