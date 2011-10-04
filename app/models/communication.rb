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
  TYPES = { :annual_report => "Annual Report",
            :newsletter => "Newsletter",
            :printed => "Printed Material"
          }
    
  include HasFile
  belongs_to :local_network

  # validates_inclusion_of :communication_type, :in => TYPES, :allow_nil => false
  validates_presence_of :title, :date
  
  def self.local_network_model_type
    :network_management
  end
  
  def type_name
    TYPES[communication_type.try(:to_sym)]
  end

  def communication_type_for_select_field
    communication_type.try(:to_sym)
  end
  
  def readable_error_messages
    error_messages = []
    errors.each do |error|
      case error
        when 'title'
          error_messages << 'Enter a title'
        when 'file'
          error_messages << 'Choose a file to upload'
       end
    end
    error_messages
  end
  
end
