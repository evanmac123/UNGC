# == Schema Information
#
# Table name: integrity_measures
#
#  id               :integer          not null, primary key
#  local_network_id :integer
#  title            :string(255)
#  policy_type      :string(255)
#  description      :text(65535)
#  date             :date
#

class IntegrityMeasure < ActiveRecord::Base
  TYPES = { :cop      => 'Communication on Progress',
            :logo     => 'Network Logo Policy',
            :dialogue => 'Dialogue Faciliation' }

  include HasFile
  belongs_to :local_network

  validates_presence_of :date, :title, :description

  def self.local_network_model_type
    :network_management
  end

  def policy_type_name
    TYPES[policy_type.try(:to_sym)]
  end

  def policy_type_for_select_field
    policy_type.try(:to_sym)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |attribute|
      case attribute
        when :date
          error_messages << 'Enter a date'
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

