# == Schema Information
#
# Table name: communications
#
#  id                 :integer(4)      not null, primary key
#  local_network_id   :integer(4)
#  title              :string(255)
#  communication_type :string(255)
#  date               :date
#

class Communication < ActiveRecord::Base
  TYPES = ["Annual Report", "NewsLetter", "Printed Material"]

  include HasFile
  belongs_to :local_network

  validates_inclusion_of :communication_type, :in => TYPES, :allow_nil => false
  validates_presence_of :title, :date
end

