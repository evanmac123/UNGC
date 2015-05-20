class AddDetailsToEvents < ActiveRecord::Migration
  def change
    add_column :events, :is_all_day, :boolean
    add_column :events, :is_online, :boolean
    add_column :events, :is_invitation_only, :boolean
    add_column :events, :priority, :integer, default: 1
    add_reference :events, :contact, index: true, foreign_key: true
    add_attachment :events, :thumbnail_image
    add_attachment :events, :banner_image
    add_column :events, :call_to_action_1_title, :string
    add_column :events, :call_to_action_1_link, :string
    add_column :events, :call_to_action_2_title, :string
    add_column :events, :call_to_action_2_link, :string
    add_column :events, :overview_description, :text
  end
end
