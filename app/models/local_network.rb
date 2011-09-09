# == Schema Information
#
# Table name: local_networks
#
#  id                                                  :integer(4)      not null, primary key
#  name                                                :string(255)
#  manager_id                                          :integer(4)
#  url                                                 :string(255)
#  state                                               :string(255)
#  created_at                                          :datetime
#  updated_at                                          :datetime
#  sg_global_compact_launch_date                       :date
#  sg_local_network_launch_date                        :date
#  sg_annual_meeting_appointments                      :boolean(1)
#  sg_annual_meeting_appointments_file_id              :integer(4)
#  sg_selected_appointees_local_network_representative :boolean(1)
#  sg_selected_appointees_steering_committee           :boolean(1)
#  sg_selected_appointees_contact_point                :boolean(1)
#  sg_established_as_a_legal_entity                    :boolean(1)
#  sg_established_as_a_legal_entity_file_id            :integer(4)
#  membership_subsidiaries                             :boolean(1)
#  membership_companies                                :integer(4)
#  membership_sme                                      :integer(4)
#  membership_micro_enterprise                         :integer(4)
#  membership_business_organizations                   :integer(4)
#  membership_csr_organizations                        :integer(4)
#  membership_labour_organizations                     :integer(4)
#  membership_civil_societies                          :integer(4)
#  membership_academic_institutions                    :integer(4)
#  membership_government                               :integer(4)
#  membership_other                                    :integer(4)
#  fees_participant                                    :boolean(1)
#  fees_amount_company                                 :integer(4)
#  fees_amount_sme                                     :integer(4)
#  fees_amount_other_organization                      :integer(4)
#  fees_amount_participant                             :integer(4)
#  fees_amount_voluntary_private                       :integer(4)
#  fees_amount_voluntary_public                        :integer(4)
#  stakeholder_company                                 :boolean(1)
#  stakeholder_sme                                     :boolean(1)
#  stakeholder_business_association                    :boolean(1)
#  stakeholder_labour                                  :boolean(1)
#  stakeholder_un_agency                               :boolean(1)
#  stakeholder_ngo                                     :boolean(1)
#  stakeholder_foundation                              :boolean(1)
#  stakeholder_academic                                :boolean(1)
#  stakeholder_government                              :boolean(1)
#

class LocalNetwork < ActiveRecord::Base
  validates_presence_of :name

  has_many :countries
  has_many :contacts
  has_many :integrity_measures
  has_many :awards
  has_many :events, :class_name => 'LocalNetworkEvent'
  has_many :mous, :class_name => 'MOU'
  has_many :meetings
  has_many :communications

  belongs_to :manager, :class_name => "Contact"
  belongs_to :sg_annual_meeting_appointments_file, :class_name => 'UploadedFile'
  belongs_to :sg_established_as_a_legal_entity_file, :class_name => 'UploadedFile'

  validates_format_of :url,
                      :with => /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix,
                      :message => "for website is invalid. Please enter one address in the format http://unglobalcompact.org/",
                      :unless => Proc.new { |local_network| local_network.url.blank? }
  
  # validates_numericality_of :fees_amount_company, :only_integer => true, :message => "should only contain numbers. No commas or periods are required."
  
  default_scope :order => 'name'
  
  STATES = { :emerging => 'Emerging', :established => 'Established' }
  
  # To link to public profiles, we associate the two regional networks with their host countries
  # Ex: NetworksAroundTheWorld/local_network_sheet/AE.html
  REGION_COUNTRY = { 'Gulf States' => 'AE', 'Nordic Network' => 'DK' }
  
  STAKEHOLDERS = {   
    :stakeholder_company              => 'Companies',
    :stakeholder_sme                  => 'SMEs',
    :stakeholder_business_association => 'Business Associations',
    :stakeholder_labour               => 'Labour',
    :stakeholder_un_agency            => 'UN Agencies',
    :stakeholder_ngo                  => 'NGOs',
    :stakeholder_foundation           => 'Foundations',
    :stakeholder_academic             => 'Academics',
    :stakeholder_government           => 'Government Entities'
  }
          
  def latest_participant
    participants.find(:first, :order => 'joined_on DESC')
  end
  
  def public_network_contacts
    contacts.network_roles_public + [manager]
  end
  
  def participants
    Organization.visible_in_local_network.where_country_id(countries.map(&:id))
  end
  
  def humanize_state
    state.try(:humanize) || ''    
  end
  
  def state_for_select_field
    state.try(:to_sym)
  end
    
  def country_code
    # if more than one country, it's a regional network, so lookup the host country
    if countries.count > 1
      REGION_COUNTRY[name]
    elsif countries.count == 1
      countries.first.code
    else
      ''
    end
  end
  
  def country_id
    if countries.count > 1
      Country.find_by_code(REGION_COUNTRY[name]).id
    elsif countries.count == 1
      countries.first.id
    end
  end
  
  def stakeholders_involved_in_governance
    selected = []
    STAKEHOLDERS.each do |key, value|
      selected << key if self.send(key.to_s)
    end
    selected
  end

  [:annual_meeting_appointments, :established_as_a_legal_entity].each do |m|
    define_method "sg_#{m}_uploaded_data=" do |file|
      self.send "sg_#{m}_file=", UploadedFile.new(uploaded_data: file, attachable: self)
    end
  end
  
  def readable_error_messages
    error_messages = []
    errors.each do |error|
      case error
        when 'url'
          error_messages << 'Please provide a website address in the format http://organization.org'
       end
    end
    error_messages
  end
  
end
