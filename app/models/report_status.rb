class ReportStatus < ActiveRecord::Base
  attr_accessible :error_message, :filename, :path, :status

  def complete!(file)
    self.path = file.path
    self.status = 1
    save!
  end

end
