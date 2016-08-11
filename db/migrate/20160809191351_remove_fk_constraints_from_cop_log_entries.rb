class RemoveFkConstraintsFromCopLogEntries < ActiveRecord::Migration
  def change
    remove_foreign_key :cop_log_entries, :contacts
    remove_foreign_key :cop_log_entries, :organizations
  end
end
