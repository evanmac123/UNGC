# == Schema Information
#
# Table name: reporting_reminder_email_statuses
#
#  id              :integer          not null, primary key
#  organization_id :integer          not null
#  success         :boolean          not null
#  message         :text(65535)
#  reporting_type  :string(255)
#  email           :string(255)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ReportingReminderEmailStatus < ActiveRecord::Base
end
