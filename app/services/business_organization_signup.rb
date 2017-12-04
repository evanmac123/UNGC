class BusinessOrganizationSignup < OrganizationSignup
  attr_reader :financial_contact
  attr_writer :invoicing_policy

  def post_initialize
    @org_type = 'business'
    org = Organization.new(organization_type: OrganizationType.sme)
    @organization = Organization::SignupForm.new(org)
    @financial_contact = Contact.new_financial_contact
    @ap_subscriptions = []
  end

  def types
    OrganizationType.business
  end

  def set_financial_contact_attributes(par)
    financial_contact.attributes = par
  end

  def prepare_financial_contact
    financial_contact.address = primary_contact.address
    financial_contact.address_more = primary_contact.address_more
    financial_contact.city = primary_contact.city
    financial_contact.state = primary_contact.state
    financial_contact.postal_code = primary_contact.postal_code
    financial_contact.country_id = primary_contact.country_id
  end
  alias_method :prefill_financial_contact_address, :prepare_financial_contact

  def after_save
    # NB we're still in a transaction here
    # add financial contact
    # fixes bug caused by storing signup and related objects in session (in rails4)
    financial_contact.roles.reload

    financial_contact.save!
    organization.contacts << financial_contact

    if @ap_subscriptions.any?
      organization = @organization.organization # Sigh, unwrap the form object
      order_service = ActionPlatform::OrderService.new(organization, financial_contact)

      @ap_subscriptions.each do |subscription|
        contact_index = subscription.contact_id
        contact = contacts[contact_index]
        order_service.subscribe(
          contact_id: contact.id,
          platform_id: subscription.platform_id,
        )
      end

      order = order_service.create_order

      if order.nil?
        raise "Failed to create action platform subscriptions order"
      end
    end

    true
  end

  def local_valid_organization?
    validate_sector
    validate_listing_status
    validate_revenue
    validate_revenue_from_sources
  end

  def listing_status_options
    ListingStatus.applicable.collect { |t| [t.name, t.id] }
  end

  def to_s
    self.inspect # HACK to make sure Honeybadger includes all relevant info
  end

  def error_messages
    super + @financial_contact.errors.full_messages
  end

  def levels_of_participation
    Organization.level_of_participations.map do |slug, _id|
      [I18n.t(slug), slug]
    end
  end

  def invoice_date_options
    invoicing_policy.options
  end

  def select_participation_level(params)
    level = params.fetch(:level_of_participation)
    real_level = if level == "lead_level"
                   "participant_level"
                 else
                   level
                 end
    organization.level_of_participation = real_level
    organization.invoice_date = params[:invoice_date]

    @ap_subscriptions = params.fetch(:subscriptions, {})
      .values
      .select { |s| s[:selected] == "1" }
      .map do |s|
        ActionPlatform::Subscription.new(
          contact_id: s[:contact_id],
          platform_id: s[:platform_id]
        )
      end
  end

  def valid_participant_level?
    validate_level_of_participation
    organization.errors.empty?
  end

  def invoicing_required?
    invoicing_policy.invoicing_required?
  end

  def valid_invoice_date?
    validate_invoice_date
    organization.errors.empty?
  end

  def action_platforms
    ActionPlatform::Platform.available_for_signup.select(:id, :name, :slug, :description)
  end

  def contacts
    super + [@financial_contact]
  end

  def financial_contact_valid?
    return false unless financial_contact.valid?

    # financial contact is otherwise valid, check for duplicate emails
    emails = [primary_contact.email, ceo.email]
    if emails.include?(financial_contact.email)
      financial_contact.errors.add(:email, "has already been taken")
      false
    else
      true
    end
  end

  private

  def invoicing_policy
    Organization::InvoicingPolicy.new(organization, organization.precise_revenue)
  end

  def validate_sector
    return if organization.sector.present?
    organization.errors.add :sector_id, "can't be blank"
  end

  def validate_listing_status
    return if organization.listing_status.present?
    organization.errors.add :listing_status_id, "can't be blank"
  end

  def validate_revenue
    return if organization.revenue.present?
    organization.errors.add :revenue, "can't be blank"
  end

  def validate_level_of_participation
    if organization.level_of_participation.blank?
      organization.errors.add :level_of_participation, "can't be blank"
    end
  end

  def validate_invoice_date
    invoicing_policy.validate(organization)
  end

  def validate_revenue_from_sources
    if organization.is_tobacco.nil?
      organization.errors.add :is_tobacco, :is_tobacco
    end
    if organization.is_landmine.nil?
      organization.errors.add :is_landmine, :is_landmine
    end
  end

end
