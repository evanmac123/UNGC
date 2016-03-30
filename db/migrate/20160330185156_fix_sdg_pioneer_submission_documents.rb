class FixSdgPioneerSubmissionDocuments < ActiveRecord::Migration
  def change
    update <<-SQL
      update
        uploaded_files
      set
        attachable_key = 'supporting_document'
      where
        attachable_type = 'SdgPioneer::Submission'
    SQL
  end
end
