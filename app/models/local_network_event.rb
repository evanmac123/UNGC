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

  validates_presence_of :title, :description, :event_type, :date, :num_participants, :gc_participant_percentage
  validates_numericality_of :num_participants, :only_integer => true, :allow_blank => true
  validates_numericality_of :gc_participant_percentage, :only_integer => true, :allow_blank => true

  default_scope :order => 'date DESC'

  before_save :set_indexed_fields, :if => :new_record?

  define_index do
    indexes title
    indexes description
    indexes file_content

    has date
    has local_network_id
    has country_id
    has 'CRC32(event_type)', :as => :event_type_crc, :type => :integer
    has 'CRC32(region)',     :as => :region_crc,     :type => :integer
    has principles(:id),     :as => :principle_ids
  end

  def set_indexed_fields
    country = local_network.countries.first

    self.attributes = {
      :country_id   => country.id,
      :region       => country.region,
      :file_content => attachments.map { |uploaded_file| FileTextExtractor.extract(uploaded_file) }.join("\n")
    }
  end

  def update_indexed_fields
    set_indexed_fields
    save
  end

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
    Principle.all_types
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
           when 'description'
             error_messages << 'Enter a description'
           when 'event_type'
             error_messages << 'Select an event type'
           when 'num_participants'
             error_messages << 'Stakeholders > Enter the number of attendees at the event. Letters or other symbols cannot be entered.'
           when 'gc_participant_percentage'
             error_messages << 'Stakeholders > Enter the approximate percentage of Global Compact participants. Letters or other symbols cannot be entered.'
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

