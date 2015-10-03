class AddContactAndCallToActionToHeadlines < ActiveRecord::Migration
  def change
    add_reference :headlines, :contact, index: true, foreign_key: true
    add_column :headlines, :call_to_action_label, :string
    add_column :headlines, :call_to_action_url, :string
  end
end
