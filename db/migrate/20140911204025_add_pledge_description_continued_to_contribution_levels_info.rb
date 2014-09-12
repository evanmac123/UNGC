class AddPledgeDescriptionContinuedToContributionLevelsInfo < ActiveRecord::Migration
  def change
    add_column :contribution_levels_infos, :pledge_description_continued, :text
  end
end
