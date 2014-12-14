class ReportStatus < ActiveRecord::Base
  attr_accessible :error_message, :filename, :path, :status, :format

  STARTED = 0
  COMPLETED = 1
  FAILED = 2

  def complete!(file)
    self.path = file.path
    self.status = COMPLETED
    save!
  end

  def failed!(error)
    self.error_message = error.message
    self.status = FAILED
    save!
  end

end
