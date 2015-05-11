class ChangeDefaultForHeadlineType < ActiveRecord::Migration
  def up
    change_column :headlines, :headline_type, :integer, :default => 1
    Headline.update_all headline_type: 1
  end

  def down
    change_column :headlines, :headline_type, :integer, :default => 0
  end
end
