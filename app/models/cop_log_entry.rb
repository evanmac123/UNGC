class CopLogEntry < ActiveRecord::Base
  serialize :params, JSON
  belongs_to :contact
  belongs_to :organization
end
