# == Schema Information
#
# Table name: cop_log_entries
#
#  id              :integer          not null, primary key
#  event           :string(255)
#  cop_type        :string(255)
#  status          :string(255)
#  error_message   :text(65535)
#  contact_id      :integer
#  organization_id :integer
#  params          :text(65535)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class CopLogEntry < ActiveRecord::Base
  serialize :params, JSON
  belongs_to :contact
  belongs_to :organization

  validates :event, presence: true
  validates :cop_type, presence: true
  validates :status, presence: true
  validates :contact_id, presence: true
  validates :organization_id, presence: true

  after_initialize do
    self.params ||= {}
  end
end
