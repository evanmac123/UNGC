class ReportStatus < ActiveRecord::Base
  STARTED = 0
  COMPLETED = 1
  FAILED = 2

  def complete!(file_path)
    self.path = file_path
    self.status = COMPLETED
    save!
  end

  def failed!(error)
    self.error_message = error.message
    self.status = FAILED
    save!
  end
end
