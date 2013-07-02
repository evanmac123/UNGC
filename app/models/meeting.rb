# == Schema Information
#
# Table name: meetings
#
#  id               :integer          not null, primary key
#  local_network_id :integer
#  meeting_type     :string(255)
#  date             :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Meeting < ActiveRecord::Base
  TYPES = { :general => "General", :governance => "Governance", :steering_commitee => "Steering Committee" }

  include HasFile
  belongs_to :local_network

  validates_presence_of :date

  def self.local_network_model_type
    :knowledge_sharing
  end

  def type_name
    TYPES[meeting_type.try(:to_sym)]
  end

  def meeting_type_for_select_field
    meeting_type.try(:to_sym)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |attribute|
      case attribute
        when :date
          error_messages << 'Select a date'
        when :file
          error_messages << 'Choose a file to upload'
       end
    end
    error_messages
  end

end

