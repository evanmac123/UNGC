# == Schema Information
#
# Table name: report_statuses
#
#  id            :integer          not null, primary key
#  status        :integer          default(0), not null
#  filename      :string(255)
#  path          :string(255)
#  error_message :text(65535)
#  format        :string(255)
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

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
