class AddCopsSupportStatementIncludeBenefits < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :support_statement_explain_benefits, :boolean
  end

  def self.down
    remove_column :communication_on_progresses, :support_statement_explain_benefits
  end
end
