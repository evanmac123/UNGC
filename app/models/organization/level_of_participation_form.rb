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
      fields = self.attribute_set.map { |a| a.name.to_s }
      attrs = contact.attributes.slice(*fields)
      new(attrs)
    end

    private

    def validate_unique_email
      if Contact.where(email: email).where.not(id: id).any?
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
  }
  validates :confirm_financial_contact_info, presence: { message: "must be accepted" }
  validates :confirm_submission, presence: { message: "must be accepted" }

  validate :invoice_date do
    if invoicing_policy.invoicing_required? && invoice_date.blank?
      errors.add :invoice_date, "can't be blank"
    end
  end

  validates :financial_contact, presence: true
  validate :financial_contact do
    unless financial_contact.valid?
      financial_contact.errors.each do |key, message|
        errors.add key, message
      end
    end
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
        organization.update!(
          precise_revenue: annual_revenue,
          level_of_participation: level_of_participation,
          invoice_date: invoice_date,
          parent_company_id: parent_company_id
        )

        # ensure the contact specified is a contact point
        primary_contact_point = organization.contacts.
          includes(:roles).
          find(contact_point_id)
        unless primary_contact_point.is?(Role.contact_point)
          primary_contact_point.roles << Role.contact_point
        end

        if financial_contact.id.present?
          c = organization.contacts.find(financial_contact.id)
          c.update!(financial_contact.attributes)
        else
          attrs = financial_contact.attributes.merge(
            roles: [Role.financial_contact])
          organization.contacts.
            financial_contacts.create!(attrs)
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
    organization.contacts.map do |contact|
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
    @invoicing_policy ||= Organization::InvoicingPolicy.new(organization)
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
