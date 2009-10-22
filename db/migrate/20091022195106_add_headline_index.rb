class AddHeadlineIndex < ActiveRecord::Migration
  def self.up
    add_index :headlines, :published_on
    add_index :headlines, :approval
  end

  def self.down
  end
end
