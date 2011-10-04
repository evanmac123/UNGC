# == Schema Information
#
# Table name: local_network_events
#
#  id                               :integer(4)      not null, primary key
#  local_network_id                 :integer(4)
#  title                            :string(255)
#  description                      :text
#  date                             :date
#  event_type                       :string(255)
#  num_participants                 :integer(4)
#  gc_participant_percentage        :integer(4)
#  stakeholder_company              :boolean(1)
#  stakeholder_sme                  :boolean(1)
#  stakeholder_business_association :boolean(1)
#  stakeholder_labour               :boolean(1)
#  stakeholder_un_agency            :boolean(1)
#  stakeholder_ngo                  :boolean(1)
#  stakeholder_foundation           :boolean(1)
#  stakeholder_academic             :boolean(1)
#  stakeholder_government           :boolean(1)
#  stakeholder_media                :boolean(1)
#  stakeholder_others               :boolean(1)
#  created_at                       :datetime
#  updated_at                       :datetime
#

class LocalNetworkEvent < ActiveRecord::Base

  TYPES = { :cop              => "COP Related Activity",
            :learning         => "Learning",
            :governance       => "Governance", 
            :outreach         => "Outreach",
            :partnership      => "Partnership",
            :policy_dialogue  => "Policy Dialogue",
            :tool_publication => "Tool Provision, Publication or Translation",
            :other            => "Other"
          }

  belongs_to :local_network
  has_and_belongs_to_many :principles
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable

  validates_presence_of :title, :event_type, :date

  def local_network_model_type
    :knowledge_sharing
  end

  def self.principle_areas
    Principle.all(:conditions => 'parent_id is null')
  end
  
  def type_name
    TYPES[event_type.try(:to_sym)]
  end

  def event_type_for_select_field
    event_type.try(:to_sym)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |error|
         case error
           when 'title'
             error_messages << 'Enter a title'
           when 'event_type'
             error_messages << 'Select an event type'
           when 'date'
             error_messages << 'Select a date'
           when 'file'
             error_messages << 'Select a file to upload'
          end
       end
    error_messages
  end

  def uploaded_attachments=(attribute_array)
    attribute_array.each do |attrs|
      self.attachments.build(attrs)
    end
  end

end

