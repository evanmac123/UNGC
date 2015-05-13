class Redesign::ContactUsForm
  include ActiveModel::Model

  attr_accessor :name, :email, :organization, :interest_ids, :focus_ids, :comments

  validates :name, :email, :comments, presence: true
  validates_format_of :email,
                      :with => /\A[A-Za-z0-9.'_%+-]+@[A-Za-z0-9'.-]+\.[A-Za-z]{2,6}\z/,
                      :message => "is not a valid email address"

  def send_email
    if valid?
      ContactUsMailer.delay.contact_us_received({
        name: self.name,
        email: self.email,
        organization: self.organization,
        interests: self.interests,
        focuses: self.focuses,
        comments: self.comments
      })
      true
    else
      false
    end
  end

  def interests
    interest_options_data.map do |option|
      return option[:name] if Array(interest_ids).include? option[:id]
    end
  end

  def focuses
    focus_options_data.map do |option|
      return option[:name] if Array(focus_ids).include? option[:id]
    end
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
        name: 'General Inquiry'
      },
      {
        id: 'reporting_cop_doe',
        name: 'Reporting (COP/COE)'
      },
      {
        id: 'events',
        name: 'Events'
      },
      {
        id: 'integrity_measures',
        name: 'Integrity Measures'
      },
      {
        id: 'copyright_inquiries',
        name: 'Copyright Inquiries'
      },
      {
        id: 'government_affairs',
        name: 'Government Affairs'
      },
      {
        id: 'media',
        name: 'Media'
      },
      {
        id: 'local_networks',
        name: 'Local Networks'
      },
      {
        id: 'global_compact_lead',
        name: 'Global Contact LEAD'
      },
      {
        id: 'sustainable_development_goals',
        name: 'Sustainable Development Goals'
      },
      {
        id: 'foundation_contribution',
        name: 'Foundation Contribution'
      }
    ]
  end

  def focus_options_data
    [
      {
        id: 'partnerships',
        name: 'Partnerships'
      },
      {
        id: 'supply_chain_sustainability',
        name: 'Supply Chain Sustainability'
      },
      {
        id: 'management_education',
        name: 'Management Education'
      },
      {
        id: 'financial_markets',
        name: 'Financial Markets'
      },
      {
        id: 'human_rights',
        name: 'Human Rights'
      },
      {
        id: 'poverty',
        name: 'Poverty'
      },
      {
        id: 'childrens_rights',
        name: 'Children\'s Rights'
      },
      {
        id: 'gender_equality',
        name: 'Gender Equality'
      },
      {
        id: 'indigenous_people',
        name: 'Indigenous People'
      },
      {
        id: 'labour_poverty',
        name: 'Labour Poverty'
      },
      {
        id: 'education',
        name: 'Education'
      },
      {
        id: 'environment',
        name: 'Environment'
      },
      {
        id: 'climate_change',
        name: 'Climate Change'
      },
      {
        id: 'water',
        name: 'Water'
      },
      {
        id: 'food_agriculture',
        name: 'Food & Agriculture'
      },
      {
        id: 'anti_corruption',
        name: 'Anti-Corruption'
      },
      {
        id: 'peace',
        name: 'Peace'
      },
      {
        id: 'rule_of_law',
        name: 'Rule of Law'
      }
    ]
  end
end
