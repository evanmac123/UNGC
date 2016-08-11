class AddAdditionalTabsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :tab_4_title, :string
    add_column :events, :tab_4_description, :text
    add_column :events, :tab_5_title, :string
    add_column :events, :tab_5_description, :text
  end
end
