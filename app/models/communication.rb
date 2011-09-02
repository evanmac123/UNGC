class Communication < ActiveRecord::Base
  TYPES = ["Annual Report", "NewsLetter", "Printed Material"]

  include HasFile
  belongs_to :local_network

  validates_inclusion_of :communication_type, :in => TYPES, :allow_nil => false
  validates_presence_of :title, :date
end

