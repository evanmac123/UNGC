class AddCopsMentionsPartnershipProject < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :mentions_partnership_project, :boolean
    add_column :communication_on_progresses, :additional_questions, :boolean
    
    remove_column :communication_on_progresses, :support_statement_lists_reason
    remove_column :communication_on_progresses, :support_statement_mentions_engagements
  end

  def self.down
    remove_column :communication_on_progresses, :mentions_partnership_project
    remove_column :communication_on_progresses, :additional_questions
    
    add_column :communication_on_progresses, :support_statement_lists_reason, :boolean
    add_column :communication_on_progresses, :support_statement_mentions_engagements, :boolean
  end
end

