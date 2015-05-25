class Redesign::ContactUsForm
  include ActiveModel::Model

  attr_accessor :name, :email, :organization, :interest_ids, :focus_ids, :comments, :magic

  validates :name, :email, :comments, presence: true
  validates_format_of :email,
                      :with => /\A[A-Za-z0-9.'_%+-]+@[A-Za-z0-9'.-]+\.[A-Za-z]{2,6}\z/,
                      :message => "is not a valid email address"

  validate :three_is_magic

  def three_is_magic
    if self.magic != "3"
      errors.add(:magic, 'invalid number')
    end
  end

  def send_email
    if valid?
      ContactUsMailer.delay.contact_us_received({
        name: self.name,
        email: self.email,
        organization: self.organization,
        interests: self.interests,
        focuses: self.focuses,
        comments: self.comments,
        to: to_addresses
      })
      true
    else
      false
    end
  end

  def to_addresses
    emails = interest_addresses.concat(focus_addresses)
    if emails.empty?
      emails << 'info@unglobalcompact.org'
    end
    emails.uniq
  end

  def interest_addresses
    interest_options_data.map do |option|
      option[:email] if Array(interest_ids).include? option[:id]
    end.reject(&:nil?)
  end

  def focus_addresses
    focus_options_data.map do |option|
      option[:email] if Array(focus_ids).include? option[:id]
    end.reject(&:nil?)
  end

  def interests
    interest_options_data.map do |option|
      option[:name] if Array(interest_ids).include? option[:id]
    end.reject(&:nil?)
  end

  def focuses
    focus_options_data.map do |option|
      option[:name] if Array(focus_ids).include? option[:id]
    end.reject(&:nil?)
  end

  def interest_options
    interest_options_data.map do |interest|
      OpenStruct.new interest
    end
  end

  def focus_options
    focus_options_data.map do |focus|
      OpenStruct.new focus
    end
  end

  def interest_options_data
    [
      {
        id: 'general_inquiry',
        name: 'General Inquiry',
        email: 'info@unglobalcompact.org'
      },
      {
        id: 'reporting_cop_doe',
        name: 'Reporting (COP/COE)',
        email: 'cop@unglobalcompact.org'
      },
      {
        id: 'events',
        name: 'Events',
        email: 'events@unglobalcompact.org'
      },
      {
        id: 'integrity_measures',
        name: 'Integrity Measures',
        email: 'social.issues@unglobalcompact.org'
      },
      {
        id: 'copyright_inquiries',
        name: 'Copyright Inquiries',
        email: 'info@unglobalcompact.org'
      },
      {
        id: 'government_affairs',
        name: 'Government Affairs',
        email: 'info@unglobalcompact.org'
      },
      {
        id: 'media',
        name: 'Media',
        email: 'info@unglobalcompact.org'
      },
      {
        id: 'local_networks',
        name: 'Local Networks',
        email: 'localnetworks@unglobalcompact.org'
      },
      {
        id: 'global_compact_lead',
        name: 'Global Contact LEAD',
        email: 'lead@unglobalcompact.org'
      },
      {
        id: 'sustainable_development_goals',
        name: 'Sustainable Development Goals',
        email: 'info@unglobalcompact.org'
      },
      {
        id: 'foundation_contribution',
        name: 'Foundation Contribution',
        email: 'info@globalcompactfoundation.org'
      }
    ]
  end

  def focus_options_data
    [
      {
        id: 'partnerships',
        name: 'Partnerships',
        email: 'partnerships@unglobalcompact.org'
      },
      {
        id: 'supply_chain_sustainability',
        name: 'Supply Chain Sustainability',
        email: 'supplychain@unglobalcompact.org'
      },
      {
        id: 'management_education',
        name: 'Management Education',
        email: 'prmecommunications@unglobalcompact.org'
      },
      {
        id: 'financial_markets',
        name: 'Financial Markets',
        email: 'financialmarkets@unglobalcompact.org'
      },
      {
        id: 'human_rights',
        name: 'Human Rights',
        email: 'social.issues@unglobalcompact.org'
      },
      {
        id: 'childrens_rights',
        name: 'Children\'s Rights',
        email: 'childrensprinciples@unglobalcompact.org'
      },
      {
        id: 'gender_equality',
        name: 'Gender Equality',
        email: 'womens-empowerment-principles@unglobalcompact.org'
      },
      {
        id: 'indigenous_people',
        name: 'Indigenous People',
        email: 'UNDRIP@unglobalcompact.org'
      },
      {
        id: 'labour',
        name: 'Labour',
        email: 'social.issues@unglobalcompact.org'
      },
      {
        id: 'poverty',
        name: 'Poverty',
        email: 'social.issues@unglobalcompact.org'
      },
      {
        id: 'education',
        name: 'Education',
        email: 'social.issues@unglobalcompact.org'
      },
      {
        id: 'environment',
        name: 'Environment',
        email: 'climatechange@unglobalcompact.org'
      },
      {
        id: 'climate_change',
        name: 'Climate Change',
        email: 'climatechange@unglobalcompact.org'
      },
      {
        id: 'water',
        name: 'Water',
        email: 'ceowatermandate@unglobalcompact.org'
      },
      {
        id: 'food_agriculture',
        name: 'Food & Agriculture',
        email: 'sustainable.agriculture@unglobalcompact.org'
      },
      {
        id: 'anti_corruption',
        name: 'Anti-Corruption',
        email: 'anticorruption@unglobalcompact.org'
      },
      {
        id: 'peace',
        name: 'Peace',
        email: 'b4p@unglobalcompact.org'
      },
      {
        id: 'rule_of_law',
        name: 'Rule of Law',
        email: 'rol@unglobalcompact.org'
      }
    ]
  end
end
