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
            :outreach         => "Outreach",
            :partnership      => "Partnership",
            :policy_dialogue  => "Policy Dialogue",
            :tool_publication => "Tool Provision, Publication or Translation",
            :other            => "Other"
          }

STAKEHOLDER_TYPES = { :stakeholder_company               => "Companies",
                      :stakeholder_sme                   => "SMEs",
                      :stakeholder_business_association  => "Business Associations",
                      :stakeholder_labour                => "Labour",
                      :stakeholder_ngo                   => "Civil Society",
                      :stakeholder_foundation            => "Foundations",
                      :stakeholder_academic              => "Academics",
                      :stakeholder_government            => "Government",
                      :stakeholder_media                 => "Media",
                      :stakeholder_un_agency             => "UN Agencies"
                     }

  belongs_to :local_network
  has_and_belongs_to_many :principles
  has_many :attachments, :class_name => 'UploadedFile', :as => :attachable, :dependent => :destroy 

  validates_presence_of :title, :event_type, :date
  
  default_scope :order => 'date DESC'
  
  def self.local_network_model_type
    :knowledge_sharing
  end

  def stakeholder_name(type)
    STAKEHOLDER_TYPES[type]
  end
  
  def stakeholders
    stakeholders = []
    STAKEHOLDER_TYPES.keys.each { |type| stakeholders << type if self[type] }
    stakeholders
  end

  def self.principle_areas
    Principle.all(:conditions => 'parent_id is null')
  end
  
  def type_name
    TYPES[event_type.try(:to_sym)]
  end

  def local_network_name
    local_network.try(:name)
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

