# == Schema Information
#
# Table name: meetings
#
#  id               :integer(4)      not null, primary key
#  local_network_id :integer(4)
#  meeting_type     :string(255)
#  date             :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Meeting < ActiveRecord::Base
  TYPES = ["Steering Committee", "General", "Governance"]

  include HasFile
  belongs_to :local_network

  validates_inclusion_of :meeting_type, :in => TYPES, :allow_nil => false
  validates_presence_of :date
end

