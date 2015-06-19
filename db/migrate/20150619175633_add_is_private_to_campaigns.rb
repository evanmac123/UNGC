class AddIsPrivateToCampaigns < ActiveRecord::Migration
  def change
    add_column :campaigns, :is_private, :boolean, default: false, index:true
  end
end
