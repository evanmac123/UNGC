class Meeting < ActiveRecord::Base
  TYPES = ["Steering Committee", "General", "Governance"]

  include HasFile
  belongs_to :local_network

  validates_inclusion_of :meeting_type, :in => TYPES, :allow_nil => false
  validates_presence_of :date
end

