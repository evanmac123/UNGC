class AddTopicAndIssueToTaggings < ActiveRecord::Migration
  def change
    add_reference :taggings, :topic, index: true
    add_foreign_key :taggings, :topics
    add_reference :taggings, :issue, index: true
    add_foreign_key :taggings, :issues
  end
end
