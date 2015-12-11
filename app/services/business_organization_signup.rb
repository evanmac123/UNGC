class BusinessOrganizationSignup < OrganizationSignup
  attr_reader :financial_contact

  def post_initialize
    @org_type = 'business'
    @organization = Organization.new organization_type: OrganizationType.sme
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

  def require_pledge?
    organization.pledge_amount.to_i > 0
  end

  def pledge_complete?
    organization.errors.clear # needed but could lead to unexpected behaviour
    if organization.pledge_amount.to_i == 0 && organization.no_pledge_reason.blank?
      organization.errors.add :no_pledge_reason, "must be selected"
      return false
    else
      return true
    end
  end

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
    if require_pledge? && !primary_contact.is?(Role.financial_contact)
      # fixes bug caused by storing signup and related objects in session (in rails4)
      financial_contact.roles.reload

      # save the financial_contact, currently it's okay for this
      # model to be empty/invalid
      if financial_contact.save
        organization.contacts << financial_contact
      end
    end
  end

  def local_valid_organization?
    validate_sector
    validate_listing_status
    validate_revenue
  end

  def listing_status_options
    ListingStatus.applicable.collect {|t| [t.name, t.id]}
  end

  def to_s
    self.inspect # HACK to make sure Honeybadger includes all relevant info
  end

  private
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
end
