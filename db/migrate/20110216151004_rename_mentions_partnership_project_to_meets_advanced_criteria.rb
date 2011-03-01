class RenameMentionsPartnershipProjectToMeetsAdvancedCriteria < ActiveRecord::Migration
  def self.up
    rename_column :communication_on_progresses, :mentions_partnership_project, :meets_advanced_criteria
  end

  def self.down
    rename_column :communication_on_progresses, :meets_advanced_criteria, :mentions_partnership_project
  end
end