class AddHeadlineTypeToHeadlines < ActiveRecord::Migration
  def change
    add_column :headlines, :headline_type, :integer, :default => 0
    add_index :headlines, :headline_type
  end
end
