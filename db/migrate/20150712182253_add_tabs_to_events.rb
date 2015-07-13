class AddTabsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :tab_1_title, :string
    add_column :events, :tab_1_description, :text
    add_column :events, :tab_2_title, :string
    add_column :events, :tab_2_description, :text
    add_column :events, :tab_3_title, :string
    add_column :events, :tab_3_description, :text
  end
end
