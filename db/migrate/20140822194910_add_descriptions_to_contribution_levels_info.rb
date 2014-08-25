class AddDescriptionsToContributionLevelsInfo < ActiveRecord::Migration
  def change
    add_column :contribution_levels_infos, :pledge_description, :string
    add_column :contribution_levels_infos, :payment_description, :string
    add_column :contribution_levels_infos, :contact_description, :string
    add_column :contribution_levels_infos, :additional_description, :string
  end
end
