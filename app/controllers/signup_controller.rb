class SignupController < ApplicationController
  before_filter :determine_navigation
  before_filter :load_objects

  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  # shows organization form
  def step1
    clean_session
    @organization.organization_type_id = @organization_types.first.id unless @organization.organization_type_id
    # check if they were referred from the JCI website
    if @organization.jci_referral? request.env["HTTP_REFERER"]
      session[:is_jci_referral] = true
      @jci_referral = true
    end
  end

  # POST from organization form
  # shows contact form
  def step2
    if params[:organization]
      @organization.attributes = params[:organization]
      session[:signup_organization] = @organization
      set_default_values
    end

    unless @organization.valid?
      redirect_to organization_step1_path(:org_type => extract_organization_type(@organization))
    end

  end

  # POST from contact form
  # shows ceo form
  def step3
    if params[:contact]
      @contact.attributes = params[:contact]
      session[:signup_contact] = @contact
      set_default_values
    end
    # business make a financial contribution (step 4), non-business upload their letter of commitment (step 6)
    @organization.attributes = params[:organization]
    @next_step = @organization.business_entity? ? organization_step4_path : organization_step6_path

    redirect_to organization_step2_path unless @contact.valid?
  end

  # POST from ceo form
  # pledge form if business organization
  def step4
    save_ceo_info_from_params_into_session
    redirect_to organization_step3_path unless @ceo.valid? and unique_emails?
    # highlight amount by assigning CSS class
    @suggested_pledge_amount = {}
    @suggested_pledge_amount[@organization.revenue.to_s] = 'highlight_suggested_amount'
    # preselect radio button
    @checked_pledge_amount = {}
    @checked_pledge_amount[@organization.revenue.to_s] = true
  end

  # POST from pledge form
  # ask for financial contact if pledge was made
  def step5
    # Financial Contact fields not included in the form, but which default to the Contact Point's
    @financial_contact.address = @contact.address
    @financial_contact.address_more = @contact.address_more
    @financial_contact.city = @contact.city
    @financial_contact.state = @contact.state
    @financial_contact.postal_code = @contact.postal_code
    @financial_contact.country_id = @contact.country_id
    @organization.attributes = params[:organization]
    redirect_to organization_step6_path unless @organization.pledge_amount.to_i > 0
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  def step6
    @organization.attributes = params[:organization]
    if @organization.pledge_amount.to_i > 0
      create_financial_contact_or_add_role_to_existing_contact
      redirect_to organization_step5_path unless @financial_contact.valid? || @contact.is?(Role.financial_contact)
    else
      save_ceo_info_from_params_into_session
    end
    redirect_to organization_step3_path unless @ceo.valid? and unique_emails?
  end

  # POST from commitment letter form
  # shows thank you page
  def step7
    @organization.attributes = params[:organization]
    if @organization.valid? && @organization.commitment_letter?
      # save all records
      @organization.save
      @contact.save
      @ceo.save
      @organization.contacts << @contact
      @organization.contacts << @ceo

      # add financial contact if a pledge was made and the existing contact has not been assigned that role
      unless @organization.pledge_amount.blank? and @contact.is?(Role.financial_contact)
        @financial_contact.save
        @organization.contacts << @financial_contact
      end

      begin
        OrganizationMailer.submission_received(@organization).deliver
        if session[:is_jci_referral]
          OrganizationMailer.submission_jci_referral_received(@organization).deliver
        end
      rescue Exception => e
       flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end

      clean_session
    else
      flash[:error] = "Please upload your Letter of Commitment. #{@organization.errors.full_messages.to_sentence}"
      redirect_to organization_step6_path
    end
  end

  def no_session
    clean_session
    redirect_to organization_step1_path(:org_type => 'business')
  end

  private
    def default_navigation
      DEFAULTS[:signup_form_path]
    end

    def load_objects
      @organization = session[:signup_organization] || Organization.new
      load_organization_types
      @contact = session[:signup_contact] || new_contact(Role.contact_point)
      @ceo = session[:signup_ceo] || new_contact(Role.ceo)
      @financial_contact = session[:financial_contact] || new_contact(Role.financial_contact)
    end

    def set_default_values
      # organization country is default for contacts
      @contact.country_id = @organization.country_id unless @contact.country

      # ceo contact fields which default to contact
      @ceo.phone = @contact.phone unless @ceo.phone
      @ceo.fax = @contact.fax unless @ceo.fax
      @ceo.address = @contact.address unless @ceo.address
      @ceo.address_more = @contact.address_more unless @ceo.address_more
      @ceo.city = @contact.city unless @ceo.city
      @ceo.state = @contact.state unless @ceo.state
      @ceo.postal_code = @contact.postal_code unless @ceo.postal_code
      @ceo.country_id = @contact.country_id unless @ceo.country
    end

    # Makes sure the CEO and Contact point don't have the same email address
    def unique_emails?
      unique = (@ceo.email.try(:downcase) != @contact.email.try(:downcase))
      @ceo.errors.add :email, "cannot be the same as the Contact Point" unless unique
      return unique
    end

    def load_organization_types
      method = ['business', 'non_business'].include?(params[:org_type]) ? params[:org_type] : 'business'
      @organization_types = OrganizationType.send method
    end

    def clean_session
      session[:signup_organization] = Organization.new
      session[:signup_contact] = new_contact(Role.contact_point)
      session[:signup_ceo] = new_contact(Role.ceo)
      session[:financial_contact] = new_contact(Role.financial_contact)
      session[:is_jci_referral] = nil
    end

    def new_contact(role)
      contact = Contact.new
      contact.role_ids = [role.id] if role
      contact
    end

    def extract_organization_type(organization)
      organization.business_entity? ? BUSINESS_PARAM : NONBUSINESS_PARAM
    end

    def save_ceo_info_from_params_into_session
      if params[:contact]
        @ceo.attributes = params[:contact]
        session[:signup_ceo] = @ceo
      end
    end

    def create_financial_contact_or_add_role_to_existing_contact
      # value from checkbox to indicate that invoice should be sent to Contact Points
      if params[:contact]
        if params[:contact][:foundation_contact].to_i == 1
          @contact.roles << Role.financial_contact
        else
          @financial_contact.attributes = params[:contact]
          session[:financial_contact] = @financial_contact
        end
      end
    end

end
