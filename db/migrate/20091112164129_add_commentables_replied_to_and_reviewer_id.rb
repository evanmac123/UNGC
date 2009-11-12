class AddCommentablesRepliedToAndReviewerId < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :replied_to, :boolean
    add_column :communication_on_progresses, :reviewer_id, :integer
    add_column :organizations, :replied_to, :boolean
    add_column :organizations, :reviewer_id, :integer
    add_column :case_stories, :replied_to, :boolean
    add_column :case_stories, :reviewer_id, :integer
  end

  def self.down
    remove_column :communication_on_progresses, :replied_to
    remove_column :communication_on_progresses, :reviewer_id
    remove_column :organizations, :replied_to
    remove_column :organizations, :reviewer_id
    remove_column :case_stories, :replied_to
    remove_column :case_stories, :reviewer_id
  end
end
