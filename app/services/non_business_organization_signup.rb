class NonBusinessOrganizationSignup < OrganizationSignup
  attr_reader :registration, :financial_contact

  def post_initialize
    @organization = Organization.new organization_type: OrganizationType.academic
    @legal_status_id = nil
    @registration = @organization.registration
    @ceo = Contact.new_ceo
  end

  def business?; false; end
  def non_business?; true; end

  def set_organization_attributes(par)
    set_legal_status(par[:organization])
    registration.attributes = par[:non_business_organization_registration]
    super #XXX
  end


  def local_valid_organization?
    if @legal_status_id.blank? && registration.number.blank?
      organization.errors.add :legal_status, "can't be blank"
    end
  end

  def valid?
    super && valid_registration?
  end

  def complete_valid?
    super && complete_valid_registration?
  end

  def valid_registration?
    registration.errors.clear

    if @legal_status_id.blank? && registration.number.blank?
      registration.errors.add :number, "can't be blank"
    end

    if registration.place.blank?
      registration.errors.add :place, "of Registration can't be blank"
    end

    if registration.authority.blank?
      registration.errors.add :authority, "can't be blank"
    end

    if registration.date.blank?
      registration.errors.add :date, "of Registration can't be blank"
    end

    !registration.errors.any?
  end

  def complete_valid_registration?
    registration.valid?
  end

  def before_save
    if @legal_status_id
      organization.legal_status = UploadedFile.find(@legal_status_id)
    end
  end

  def after_save
    registration.save
  end

  private

    def set_legal_status(org)
      if org && org[:legal_status]
        lg = UploadedFile.new attachable_type: 'Organization', attachable_key: Organization::ORGANIZATION_FILE_TYPES[:legal_status]
        lg.attachment = org[:legal_status]
        lg.save!
        @legal_status_id = lg.id
        org.delete(:legal_status)
      end
    end
end
