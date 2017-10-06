class BusinessOrganizationSignup < OrganizationSignup
  attr_reader :financial_contact
  attr_writer :invoicing_policy

  def post_initialize
    @org_type = 'business'
    org = Organization.new(organization_type: OrganizationType.sme)
    @organization = Organization::SignupForm.new(org)
    @financial_contact = Contact.new_financial_contact
  end

  def types
    OrganizationType.business
  end

  def set_financial_contact_attributes(par)
    if par[:foundation_contact].to_i == 1
      primary_contact.roles << Role.financial_contact
    else
      financial_contact.attributes = par
    end
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

  # checks the organization's country and Local Network to display correct pledge form
  def pledge_form_type
    organization.collaborative_funding_model? ? 'pledge_form_collaborative' : 'pledge_form_independent'
  end

  def set_organization_attributes(params)
    super
    if organization.collaborative_funding_model?
      organization.pledge_amount ||= Organization::COLLABORATIVE_PLEDGE_LEVELS[organization.revenue]
    else
      organization.pledge_amount ||= Organization::INDEPENDENT_PLEDGE_LEVELS[organization.revenue]
    end
  end

  def after_save
    # add financial contact if a pledge was made and the existing contact has not been assigned that role
    unless primary_contact.is?(Role.financial_contact)
      # fixes bug caused by storing signup and related objects in session (in rails4)
      financial_contact.roles.reload

      # save the financial_contact, currently it's okay for this
      # model to be empty/invalid
      if financial_contact.save
        organization.contacts << financial_contact
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
    organization.level_of_participation = params.fetch(:level_of_participation)
    organization.invoice_date = params[:invoice_date]
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

  private

  def invoicing_policy
    @invoicing_policy ||= Organization::InvoicingPolicy.new(organization)
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
    if invoicing_required? && organization.invoice_date.blank?
      organization.errors.add :invoice_date, "can't be blank"
    end
  end

  def validate_revenue_from_sources
    if organization.is_tobacco.nil?
      organization.errors.add :is_tobacco, :is_tobacco
    end
    if organization.is_landmine.nil?
      organization.errors.add :is_landmine, :is_landmine
    end
    if organization.is_biological_weapons.nil?
      organization.errors.add :is_biological_weapons, :is_biological_weapons
    end
  end

end
