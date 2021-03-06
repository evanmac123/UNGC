# == Schema Information
#
# Table name: local_network_events
#
#  id                               :integer          not null, primary key
#  local_network_id                 :integer
#  title                            :string(255)
#  description                      :text
#  date                             :date
#  event_type                       :string(255)
#  num_participants                 :integer
#  gc_participant_percentage        :integer
#  stakeholder_company              :boolean
#  stakeholder_sme                  :boolean
#  stakeholder_business_association :boolean
#  stakeholder_labour               :boolean
#  stakeholder_un_agency            :boolean
#  stakeholder_ngo                  :boolean
#  stakeholder_foundation           :boolean
#  stakeholder_academic             :boolean
#  stakeholder_government           :boolean
#  stakeholder_media                :boolean
#  stakeholder_others               :boolean
#  created_at                       :datetime
#  updated_at                       :datetime
#  country_id                       :integer
#  region                           :string(255)
#  file_content                     :text
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

  validates_presence_of :title,
                        :description,
                        :event_type,
                        :date,
                        :num_participants,
                        :gc_participant_percentage,
                        :local_network
  validates_numericality_of :num_participants, :only_integer => true, :allow_blank => true
  validates_numericality_of :gc_participant_percentage, :only_integer => true, :less_than_or_equal_to => 100, :allow_blank => true
  validate :must_have_attachment
  validate :local_network_must_have_country

  default_scope { order('date DESC') }

  before_save :set_indexed_fields, :if => :new_record?

  def must_have_attachment
    errors.add(:attachments) if attachments.empty?
  end

  def set_indexed_fields
    country = local_network.country

    self.attributes = {
      :country_id   => country.id,
      :region       => country.region,
    }
    extract_attachment_content
  end

  def extract_attachment_content
    str = attachments.map { |uploaded_file| FileTextExtractor.extract(uploaded_file) }.join("\n")
    self.file_content = str.mb_chars.limit(65530).to_s
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

  def covers?(issue)
    principles.include? Principle.by_type(issue)
  end

  def readable_error_messages
    error_messages = []
    errors.each do |attribute|
     case attribute
       when :title
         error_messages << 'Enter a title'
       when :description
         error_messages << 'Enter a description'
       when :event_type
         error_messages << 'Select an event type'
       when :num_participants
         error_messages << 'Stakeholders > Enter the number of attendees at the event. Letters or other symbols cannot be entered.'
       when :gc_participant_percentage
         error_messages << 'Stakeholders > Enter a number between 0 and 100 indicating the approximate percentage of Global Compact participants.'
       when :date
         error_messages << 'Select a date'
       when :attachments
         error_messages << 'Files > Select a file to upload'
      end
    end
    error_messages
  end

  def uploaded_attachments=(attribute_array)
    attribute_array.each do |attrs|
      self.attachments.build(attrs)
    end
  end

  def local_network_must_have_country
    if local_network.country.nil?
      errors.add(:local_network, "must have at least 1 country")
    end
  end

end

