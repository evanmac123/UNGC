class CreateCaseStoriesPrinciples < ActiveRecord::Migration
  def self.up
    create_table :case_stories_principles, :id => false do |t|
      t.integer :case_story_id
      t.integer :principle_id
    end
  end

  def self.down
    drop_table :case_stories_principles
  end
end
