# == Schema Information
#
# Table name: local_networks
#
#  id                                                  :integer          not null, primary key
#  name                                                :string(255)
#  url                                                 :string(255)
#  state                                               :string(255)
#  created_at                                          :datetime
#  updated_at                                          :datetime
#  sg_global_compact_launch_date                       :date
#  sg_local_network_launch_date                        :date
#  sg_annual_meeting_appointments                      :boolean
#  sg_annual_meeting_appointments_file_id              :integer
#  sg_selected_appointees_local_network_representative :boolean
#  sg_selected_appointees_steering_committee           :boolean
#  sg_selected_appointees_contact_point                :boolean
#  sg_established_as_a_legal_entity                    :boolean
#  sg_established_as_a_legal_entity_file_id            :integer
#  membership_subsidiaries                             :boolean
#  membership_companies                                :integer
#  membership_sme                                      :integer
#  membership_micro_enterprise                         :integer
#  membership_business_organizations                   :integer
#  membership_csr_organizations                        :integer
#  membership_labour_organizations                     :integer
#  membership_civil_societies                          :integer
#  membership_academic_institutions                    :integer
#  membership_government                               :integer
#  membership_other                                    :integer
#  fees_participant                                    :boolean
#  fees_amount_company                                 :integer
#  fees_amount_sme                                     :integer
#  fees_amount_other_organization                      :integer
#  fees_amount_participant                             :integer
#  fees_amount_voluntary_private                       :integer
#  fees_amount_voluntary_public                        :integer
#  stakeholder_company                                 :boolean
#  stakeholder_sme                                     :boolean
#  stakeholder_business_association                    :boolean
#  stakeholder_labour                                  :boolean
#  stakeholder_un_agency                               :boolean
#  stakeholder_ngo                                     :boolean
#  stakeholder_foundation                              :boolean
#  stakeholder_academic                                :boolean
#  stakeholder_government                              :boolean
#  twitter                                             :string(255)
#  facebook                                            :string(255)
#  linkedin                                            :string(255)
#  funding_model                                       :string(255)
#  description                                         :text(65535)
#  image_file_name                                     :string(255)
#  image_content_type                                  :string(255)
#  image_file_size                                     :integer
#  image_updated_at                                    :datetime
#  business_model                                      :integer
#  invoice_managed_by                                  :integer
#  invoice_options_available                           :integer
#  invoice_currency                                    :string(255)
#

class LocalNetwork < ActiveRecord::Base
  validates_presence_of :name

  has_attached_file :image,
    url: "/system/:class/:attachment/:id/:style/:filename"

    do_not_validate_attachment_file_type :image

  has_many :countries
  has_many :contacts
  has_many :integrity_measures
  has_many :awards
  has_many :events, :class_name => 'LocalNetworkEvent'
  has_many :mous, :class_name => 'Mou'
  has_many :meetings
  has_many :communications
  has_many :announcements
  has_many :annual_reports
  has_one  :contribution_levels_info
  has_one  :contribution_description

  belongs_to :sg_annual_meeting_appointments_file, :class_name => 'UploadedFile'
  belongs_to :sg_established_as_a_legal_entity_file, :class_name => 'UploadedFile'

  after_commit Crm::CommitHooks.new(:create), on: :create
  after_commit Crm::CommitHooks.new(:update), on: :update
  after_commit Crm::CommitHooks.new(:destroy), on: :destroy

  validates_format_of :url,
                      :with => /\A(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?\z/ix,
                      :message => "for website is invalid. Please enter one address in the format http://unglobalcompact.org/",
                      :unless => Proc.new { |local_network| local_network.url.blank? }

  validates :url, length: { maximum: 255, too_long: "has a %{count} character limit" }

  accepts_nested_attributes_for :contribution_levels_info

  NUMERIC =  [:membership_companies, :membership_sme, :membership_micro_enterprise,
              :membership_business_organizations, :membership_csr_organizations, :membership_labour_organizations,
              :membership_civil_societies, :membership_academic_institutions, :membership_government, :membership_other,
              :fees_amount_company, :fees_amount_sme, :fees_amount_other_organization, :fees_amount_participant,
              :fees_amount_voluntary_private, :fees_amount_voluntary_public]

  NUMERIC.each do |attribute|
    validates_numericality_of attribute, :only_integer => true, :allow_blank => true
  end

  default_scope { order('local_networks.name') }
  scope :where_region, lambda { |region| joins(:countries).where(countries: {region: region }).includes(:countries) }
  scope :where_state, lambda { |state| where(state: state) }
  scope :regional_centers, lambda { where(state: :regional_center) }
  scope :no_regional_centers, lambda { where(state: NO_REGIONAL_CENTER_STATES) }
  scope :active_networks, lambda { where(state: LN_ACTIVE_STATES) }

  STATES = {
    :emerging        => 'Emerging',
    :active          => 'Active',
    :advanced        => 'Advanced',
    :inactive        => 'Inactive',
    :regional_center => 'Regional Center'
  }
  NO_REGIONAL_CENTER_STATES = STATES.keys.reject { |key| key == :regional_center }
  LN_ACTIVE_STATES = STATES.keys.reject { |key| key == :inactive }

  # To link to public profiles, we associate the two regional networks with their host countries
  # Ex: NetworksAroundTheWorld/local_network_sheet/AE.html
  REGION_COUNTRY = { 'Nordic Countries' => 'DK' }

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

  enum business_model: {
    revenue_sharing: 1,
    global_local:  2,
    not_yet_decided: 3,
  }

  enum invoice_managed_by: {
    gco: 1,
    local_network: 2,
    on_hold: 3,
    global_or_local: 4
  }

  enum invoice_options_available: {
    no: 0,
    yes: 1,
  }

  def latest_participant
    participants.order(joined_on: :desc).first
  end

  def public_network_contacts
    contacts.for_roles(Role.network_roles_public)
  end

  def participants
    Organization.visible_in_local_network.where_country_id(countries.map(&:id))
  end

  def humanize_state
    STATES[state&.to_sym] || ''
  end

  def state_for_select_field
    state&.to_sym
  end

  def region
    Country.find_by_code(country_code)&.region
  end

  def regional_center_countries
    Country.where(regional_center_id: self.id)
  end

  def regional_center?
    state.to_s == 'regional_center'
  end

  def region_name
    Country::REGIONS[country&.region&.to_sym]
  end

  def country_code
    country&.code || ''
  end

  def country
    case countries.count
    when 0
      Country.find_by(regional_center_id: self.id)
    when 1
      countries.first
    else
      # if more than one country, it's a regional network, so lookup the host country
      countries.find_by(code: REGION_COUNTRY[name])
    end
  end

  def country_id
    country&.id
  end

  def country_name
    country&.name
  end

  def stakeholders_involved_in_governance
    selected = []
    STAKEHOLDERS.each do |key, _value|
      selected << key if self.send(key.to_s)
    end
    selected
  end

  def last_approved_mou_year
    if mous.any?
      year = mous.first.year.year.to_s
      if mous.first.mou_type == 'in_review'
        year += " (#{Mou::TYPES[:in_review]})"
      else
        year
      end
    end
  end

  [:annual_meeting_appointments, :established_as_a_legal_entity].each do |m|
    define_method "sg_#{m}_attachment=" do |file|
      self.send "sg_#{m}_file=", UploadedFile.new(attachment: file, attachable: self)
    end
  end

  def readable_error_messages
    error_messages = []
    fee_error_messages = ''
    errors.each do |attribute|
      if NUMERIC.include?(attribute)
        fee_error_messages = 'Please use whole numbers without decimals or commas'
      end

      case attribute
        when :url
          error_messages << 'Please provide a website address in the format http://organization.org'
      end
    end

    fee_error_messages.present? ? error_messages << fee_error_messages : error_messages
  end

  def contribution_levels
    if contribution_levels_info.nil?
      self.contribution_levels_info = ContributionLevelsInfo.new(local_network_id: self.id)
    end
    self.contribution_levels_info
  end

end
