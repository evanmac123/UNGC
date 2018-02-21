# == Schema Information
#
# Table name: awards
#
#  id               :integer          not null, primary key
#  local_network_id :integer
#  title            :string(255)
#  description      :text
#  award_type       :string(255)
#  date             :date
#  created_at       :datetime
#  updated_at       :datetime
#

class Award < ActiveRecord::Base
  TYPES = { :cop => 'Communication on Progress',
            :principles => 'Global Compact - Ten Principles',
            :partnerships => 'Partnerships for Development' }

  include HasFile
  belongs_to :local_network
  validates_presence_of :title, :description, :date

  def self.local_network_model_type
    :knowledge_sharing
  end

  def type_name
    TYPES[award_type.try(:to_sym)]
  end

  def award_type_for_select_field
    award_type.try(:to_sym)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |attribute|
      case attribute
        when :date
          error_messages << 'Select a date'
        when :title
          error_messages << 'Enter a title'
        when :description
          error_messages << 'Enter a description'
        when :file
          error_messages << 'Choose a file to upload'
       end
    end
    error_messages
  end
end
