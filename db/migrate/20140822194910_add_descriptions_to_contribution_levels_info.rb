class AddDescriptionsToContributionLevelsInfo < ActiveRecord::Migration
  def change
    add_column :contribution_levels_infos, :pledge_description, :text
    add_column :contribution_levels_infos, :payment_description, :text
    add_column :contribution_levels_infos, :contact_description, :text
    add_column :contribution_levels_infos, :additional_description, :text
  end
end
