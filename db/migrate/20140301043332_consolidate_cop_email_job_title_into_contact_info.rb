class ConsolidateCopEmailJobTitleIntoContactInfo < ActiveRecord::Migration
  def up
    CommunicationOnProgress.transaction do
      connection.update 'update communication_on_progresses set contact_info = concat_ws("\r\n", contact_info, job_title, email) where contact_info not REGEXP "\n";'
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
