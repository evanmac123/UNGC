class DropCaseStoriesPrinciples < ActiveRecord::Migration
  def change
    drop_table :case_stories_principles
  end
end
