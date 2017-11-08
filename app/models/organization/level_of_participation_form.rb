class Organization::LevelOfParticipationForm
  include Virtus.model
  include ActiveModel::Model
  attr_writer :invoicing_policy

  class FinancialContact
    include Virtus.model
    include ActiveModel::Model

    attribute :id, Integer
    attribute :prefix, String
    attribute :first_name, String
    attribute :middle_name, String
    attribute :last_name, String
    attribute :job_title, String
    attribute :email, String
    attribute :phone, String
    attribute :fax, String
    attribute :address, String
    attribute :address_more, String
    attribute :city, String
    attribute :state, String
    attribute :postal_code, String
    attribute :country_id, String

    validates_presence_of(
      :prefix,
      :first_name,
      :last_name,
      :job_title,
      :email,
      :phone,
      :address,
      :city,
      :country_id
    )

    validate :validate_unique_email

    def self.from(contact)
      attrs = contact.attributes.slice(*keys)
      new(attrs)
    end

    def self.keys
      attribute_set.map { |a| a.name.to_s }
    end

    private

    def validate_unique_email
      # Manually look for duplicate emails since ActiveRecord
      # can't do it for us here.
      query = Contact.where(email: email)

      # It's not a duplicate if it belongs to the contact already
      if id.present?
        query = query.where.not(id: id)
      end

      if query.any?
        errors.add :email, "has already been taken"
      end
    end

  end

  attribute :organization, Organization
  attribute :level_of_participation, String
  attribute :contact_point_id, Integer
  attribute :is_subsidiary, Boolean
  attribute :parent_company_name, String
  attribute :parent_company_id, Integer
  attribute :annual_revenue, MoneyType
  attribute :confirm_financial_contact_info, Boolean
  attribute :confirm_submission, Boolean
  attribute :invoice_date, Date

  attribute :financial_contact, FinancialContact
  attribute :financial_contact_action, String
  attribute :financial_contact_id, Integer

  validates :organization, presence: true
  validates :level_of_participation, presence: true
  validates :contact_point_id, presence: true
  validates :is_subsidiary, inclusion: {
    in: [true, false], message: "must be indicated"
  }
  validates :parent_company_id, presence: true,
    if: :is_subsidiary

  validates :annual_revenue, presence: true,
    numericality: {
    greater_than: 0,
    less_than_or_equal_to: 92_000_000_000_000_000,
    message: "must be less than $US 92,000,000,000,000,000"
  }

  validates :confirm_financial_contact_info, presence: { message: "must be accepted" }
  validates :confirm_submission, presence: { message: "must be accepted" }

  validate :invoice_date do
    invoicing_policy.validate(self)
  end

  validates :financial_contact, presence: true, if: :financial_contact_required?

  validate :financial_contact do
    if financial_contact_required? && financial_contact.invalid?
      financial_contact.errors.each do |key, message|
        errors.add key, message
      end
    end
  end

  def financial_contact_required?
    financial_contact_action == "create"
  end

  def self.from(organization)
    parent_company = organization.parent_company

    params = {
      organization: organization,
      level_of_participation: organization.level_of_participation,
      contact_point_id: organization.contacts.contact_points.first.try!(:id),
      is_subsidiary: parent_company.present?,
      parent_company_name: parent_company.try!(:name),
      parent_company_id: parent_company.try!(:id),
      annual_revenue: organization.precise_revenue,
      invoice_date: organization.invoice_date,
    }

    financial_contact_id = organization.contacts.financial_contacts.pluck(:id).first
    if financial_contact_id.present?
      params.merge!(
        financial_contact_id: financial_contact_id,
        financial_contact_action: "choose"
      )
    end

    self.new(params)
  end

  def engagement_year
    Time.zone.now.year + 1
  end

  def invoicing_required?
    invoicing_policy.invoicing_required?
  end

  def save
    if valid?
      Organization.transaction do
        attrs = {
          precise_revenue: annual_revenue,
          level_of_participation: level_of_participation,
          invoice_date: invoice_date,
        }

        # Ignore companies who mark themselves as their own parents
        unless parent_company_id == organization.id
          attrs[:parent_company_id] = parent_company_id
        end

        organization.update!(attrs)

        # ensure the contact specified is a contact point
        ensure_in_role(contact_point_id, Role.contact_point)

        case financial_contact_action
        when "choose"
          # load the selected contact and ensure they have the financial contact role
          ensure_in_role(financial_contact_id, Role.financial_contact)
        when "create"
          # create a new financial contact with the attribute given
          attrs = financial_contact.attributes.merge(
            roles: [Role.financial_contact])
          organization.contacts.
            financial_contacts.
            create!(attrs)
        else
          raise "Unexpected financial_contact_action: >>#{financial_contact_action}<<"
        end

        stream_name = "organization_#{organization.id}"
        EventPublisher.publish selected_level_of_participation, to: stream_name
        EventPublisher.publish invoice_date_chosen, to: stream_name
        EventPublisher.publish parent_company_identified, to: stream_name if parent_company_id.present?
        EventPublisher.publish annual_revenue_changed, to: stream_name

        @is_persisted = true

        true
      end
    end
  end
  alias_method :save!, :save

  def persisted?
    @is_persisted
  end

  def organization_contacts
    organization.contacts.with_login.map do |contact|
      [contact.name, contact.id]
    end
  end

  def countries
    Country.pluck(:name, :id)
  end

  def invoice_date_options
    invoicing_policy.options
  end

  private

  def invoicing_policy
    Organization::InvoicingPolicy.new(organization, annual_revenue)
  end

  def ensure_in_role(contact_id, role)
    contact = organization.contacts.
      includes(:roles).
      find(contact_id)
    unless contact.is?(role)
      contact.roles << role
    end
  end

  def selected_level_of_participation
    DomainEvents::OrganizationSelectedLevelOfParticipation.new(data: {
      level_of_participation: level_of_participation
    })
  end

  def invoice_date_chosen
    DomainEvents::OrganizationInvoiceDateChosen.new(data: {
      invoice_date: invoice_date
    })
  end

  def parent_company_identified
    DomainEvents::OrganizationParentCompanyIdentified.new(data: {
      parent_company_id: parent_company_id
    })
  end

  def annual_revenue_changed
    DomainEvents::OrganizationAnnualRevenueChanged.new(data: {
      annual_revenue: annual_revenue
    })
  end

end
