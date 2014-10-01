class RemoveDescriptionsFromContributionLevelInfo < ActiveRecord::Migration
  def up
    remove_column :contribution_levels_infos, :pledge_description
    remove_column :contribution_levels_infos, :pledge_description_continued
    remove_column :contribution_levels_infos, :payment_description
    remove_column :contribution_levels_infos, :contact_description
    remove_column :contribution_levels_infos, :additional_description
  end

  def down
    add_column :contribution_levels_infos, :pledge_description, :text
    add_column :contribution_levels_infos, :pledge_description_continued, :text
    add_column :contribution_levels_infos, :payment_description, :text
    add_column :contribution_levels_infos, :contact_description, :text
    add_column :contribution_levels_infos, :additional_description, :text
  end
end
