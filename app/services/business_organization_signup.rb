class BusinessOrganizationSignup < OrganizationSignup
  attr_reader :financial_contact

  def post_initialize
    @organization = Organization.new organization_type: OrganizationType.sme
    @ceo = Contact.new_ceo
    @financial_contact = Contact.new_financial_contact
  end

  def business?; true; end
  def non_business?; false; end
  def org_type; 'business'; end

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

  def has_pledge?
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

  def local_set_organization_attributes
    organization.pledge_amount ||= Organization::COLLABORATIVE_PLEDGE_LEVELS[organization.revenue]
  end

  def after_save
    # add financial contact if a pledge was made and the existing contact has not been assigned that role
    if has_pledge? && !primary_contact.is?(Role.financial_contact)
      financial_contact.save
      organization.contacts << financial_contact
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

