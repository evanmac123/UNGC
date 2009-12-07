class AddCopsSupportStatementSignee < ActiveRecord::Migration
  def self.up
    add_column :communication_on_progresses, :support_statement_signee, :string
    remove_column :communication_on_progresses, :support_statement_signed
  end

  def self.down
    remove_column :communication_on_progresses, :support_statement_signee
    add_column :communication_on_progresses, :support_statement_signed, :boolean
  end
end
