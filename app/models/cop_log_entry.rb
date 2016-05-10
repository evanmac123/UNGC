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
