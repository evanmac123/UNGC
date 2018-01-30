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

  attribute :subscriptions, Hash[Integer, ActionPlatform::SubscriptionForm], default: {}
  attribute :accept_platform_removal, Boolean

  validates :organization, presence: true
  validates :level_of_participation, inclusion: {
    message: "must be given",
    in: [
      "signatory_level",
      "participant_level",
      "lead_level"
    ]
  }
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
    message: "must be greater than 0 and less than $US 92,000,000,000,000,000"
  }

  validates :financial_contact_action, presence: true
  validates :confirm_financial_contact_info, presence: { message: "must be accepted" }
  validates :confirm_submission, presence: { message: "must be accepted" }
  validates :accept_platform_removal,
    presence: { message: "policy must be accepted" },
    if: :lead_level?
  validates :financial_contact, presence: true, if: :financial_contact_required?

  validate :invoice_date do
    invoicing_policy.validate(self)
  end

  validate :validate_subscriptions, if: :lead_level?

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
    Time.current.year
  end

  def invoicing_required?
    invoicing_policy.invoicing_required?
  end

  def invoicing_options
    invoicing_policy.to_h
  end

  def platforms_with_subscriptions
    @_platforms ||= ActionPlatform::Platform.available_for_signup
    @_platforms.map do |platform|
      [
        platform,
        organization.action_platform_subscriptions.active_at.fetch(platform.id) {
          ActionPlatform::SubscriptionForm.new(platform_id: platform.id)
        }
      ]
    end
  end

  def contacts
    organization.contacts.select(:id, :first_name, :last_name).map do |c|
      [c.name, c.id]
    end
  end

  def save
    if valid?
      organization.precise_revenue = annual_revenue
      organization.invoice_date = invoice_date

      if level_of_participation == "lead_level"
        organization.level_of_participation = "participant_level"
      else
        organization.level_of_participation = level_of_participation
      end

      # Ignore companies who mark themselves as their own parents
      unless parent_company_id == organization.id
        organization.parent_company_id = parent_company_id
      end

      level_of_participation_chosen = organization.level_of_participation.present?
      invoice_date_chosen = organization.invoice_date.present? && organization.invoice_date_changed?
      parent_company_identified = organization.parent_company_id.present? && organization.parent_company_id_changed?
      annual_revenue_changed = organization.precise_revenue_cents_changed?

      order_service = nil
      Organization.transaction do
        organization.save!

        # ensure the contact specified is a contact point
        ensure_in_role(contact_point_id, Role.contact_point)

        # create or update the finanicial contact
        financial_contact_record = create_financial_contact(organization)

        # Create any Action Platform Subscriptions
        order_service = ActionPlatform::OrderService.new(organization, financial_contact_record)
        if selected_subscriptions.any?
          selected_subscriptions.each do |params|
            order_service.subscribe(
              contact_id: params.contact_id,
              platform_id: params.platform_id
            )
          end

          order_service.create_order_without_notifications
        end

        stream_name = "organization_#{organization.id}"
        EventPublisher.publish(level_of_participation_event, to: stream_name) if level_of_participation_chosen
        EventPublisher.publish(invoice_date_chosen_event, to: stream_name) if invoice_date_chosen
        EventPublisher.publish(parent_company_identified_event, to: stream_name) if parent_company_identified
        EventPublisher.publish(annual_revenue_changed_event, to: stream_name) if annual_revenue_changed
      end

      if level_of_participation_chosen && organization&.local_network&.contacts&.network_contacts&.exists?
        OrganizationMailer.level_of_participation_chosen(organization).deliver_later
      end

      order_service.send_notifications_for_successful_order

      @is_persisted = true
      true
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

  def selected_subscriptions
    subscriptions.values.select(&:selected)
  end

  private

  def create_financial_contact(organization)
    case financial_contact_action
    when "choose"
      # load the selected contact and ensure they have the financial contact role
      ensure_in_role(financial_contact_id, Role.financial_contact)
    when "create"
      # create a new financial contact with the attribute given
      attrs = financial_contact.attributes.merge(roles: [Role.financial_contact])
      organization.contacts.financial_contacts.create!(attrs)
    else
      raise "Unexpected financial_contact_action: >>#{financial_contact_action}<<"
    end
  end

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
    contact
  end

  def level_of_participation_event
    DomainEvents::OrganizationSelectedLevelOfParticipation.new(data: {
      id: organization.id,
      level_of_participation: level_of_participation
    })
  end

  def invoice_date_chosen_event
    DomainEvents::OrganizationInvoiceDateChosen.new(data: {
      invoice_date: invoice_date
    })
  end

  def parent_company_identified_event
    DomainEvents::OrganizationParentCompanyIdentified.new(data: {
      parent_company_id: parent_company_id
    })
  end

  def annual_revenue_changed_event
    DomainEvents::OrganizationAnnualRevenueChanged.new(data: {
      annual_revenue: annual_revenue
    })
  end

  def validate_subscriptions
    selected_subscriptions.each do |subscription|
      if subscription.contact_id.blank?
        errors.add(:subscriptions, "a contact must be provided for each Action Platform selected")
      end
    end
  end

  def lead_level?
    level_of_participation.to_s == "lead_level"
  end

  def create_action_platform_subscriptions(organization, financial_contact)
  end
end
