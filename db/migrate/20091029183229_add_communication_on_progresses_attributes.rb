class AddCommunicationOnProgressesAttributes < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :include_continued_support_statement, :boolean
    add_column :communication_on_progresses, :support_statement_signed, :boolean
    add_column :communication_on_progresses, :support_statement_lists_reason, :boolean
    add_column :communication_on_progresses, :support_statement_mentions_engagements, :boolean        
    add_column :communication_on_progresses, :format, :string
    
    add_column :communication_on_progresses, :references_human_rights, :boolean
    add_column :communication_on_progresses, :references_labour, :boolean
    add_column :communication_on_progresses, :references_environment, :boolean
    add_column :communication_on_progresses, :references_anti_corruption, :boolean

    add_column :communication_on_progresses, :measures_human_rights_outcomes, :boolean
    add_column :communication_on_progresses, :measures_labour_outcomes, :boolean
    add_column :communication_on_progresses, :measures_environment_outcomes, :boolean
    add_column :communication_on_progresses, :measures_anti_corruption_outcomes, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :include_continued_support_statement
    remove_column :communication_on_progresses, :support_statement_signed
    remove_column :communication_on_progresses, :support_statement_lists_reason
    remove_column :communication_on_progresses, :support_statement_mentions_engagements
    remove_column :communication_on_progresses, :format
    
    remove_column :communication_on_progresses, :references_human_rights
    remove_column :communication_on_progresses, :references_labour
    remove_column :communication_on_progresses, :references_environment
    remove_column :communication_on_progresses, :references_anti_corruption

    remove_column :communication_on_progresses, :measures_human_rights_outcomes
    remove_column :communication_on_progresses, :measures_labour_outcomes
    remove_column :communication_on_progresses, :measures_environment_outcomes
    remove_column :communication_on_progresses, :measures_anti_corruption_outcomes
  end
end
