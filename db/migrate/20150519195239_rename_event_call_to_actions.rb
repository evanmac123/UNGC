class RenameEventCallToActions < ActiveRecord::Migration
  def change
    rename_column :events, :call_to_action_1_title, :call_to_action_1_label
    rename_column :events, :call_to_action_1_link, :call_to_action_1_url
    rename_column :events, :call_to_action_2_title, :call_to_action_2_label
    rename_column :events, :call_to_action_2_link, :call_to_action_2_url
  end
end
