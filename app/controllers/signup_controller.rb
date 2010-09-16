class SignupController < ApplicationController
  before_filter :determine_navigation
  before_filter :load_objects
  
  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  # shows organization form
  def step1
    clean_session
    @organization.organization_type_id = @organization_types.first.id unless @organization.organization_type_id
  end
  
  # POST from oganization form
  # shows contact form
  def step2
    if params[:organization]
      @organization.attributes = params[:organization]
      session[:signup_organization] = @organization
      set_default_values
    end
    
    redirect_to organization_step1_path(:org_type => extract_organization_type(@organization)) unless @organization.valid?
  end
  
  # POST from contact form
  # shows ceo form
  def step3
    if params[:contact]
      @contact.attributes = params[:contact]
      session[:signup_contact] = @contact
      set_default_values    
    end
    
    # skip pledge form for non-business
    @organization.attributes = params[:organization]
    # session[:signup_organization] @organization.attributes = session[:signup_organization]
    @next_step = @organization.business_entity? ? organization_step4_path : organization_step5_path
    
    redirect_to organization_step2_path unless @contact.valid?
  end

  # POST from ceo form
  # pledge form if business organization
  def step4
    if params[:contact]
      @ceo.attributes = params[:contact]
      session[:signup_ceo] = @ceo
    end
    redirect_to organization_step3_path unless @ceo.valid? and unique_emails?
  end

  # POST from ceo or pledge form
  # shows commitment letter form
  def step5
    @organization.attributes = params[:organization]
    @ceo.attributes = params[:contact]
    if params[:contact]
      # @financial_contact.attributes = @contact.attributes
      session[:signup_ceo] = @ceo
    end
    # redirect if financial contact is not valid
    # redirect_to organization_step3_path unless @financial_contact.valid?
    redirect_to organization_step3_path unless @ceo.valid? and unique_emails?
  end
  
  # POST from commitment letter form
  # shows thank you page
  def step6
    @organization.attributes = params[:organization]
    if @organization.valid? && @organization.commitment_letter?
      # save all records
      @organization.save
      @contact.save
      @ceo.save
      @organization.contacts << @contact
      @organization.contacts << @ceo
      
      OrganizationMailer.deliver_submission_received(@organization)
      clean_session
    else
      flash[:error] = "Please upload your Letter of Commitment. #{@organization.errors.full_messages.to_sentence}"
      redirect_to organization_step5_path
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
      @financial_contact = session[:signup_contact] || new_contact(Role.financial_contact)
    end
    
    def set_default_values
      # organization country is default for contacts
      @contact.country_id = @organization.country_id unless @contact.country
      
      # ceo contact fields defaults to contact
      @ceo.address = @contact.address unless @ceo.address
      @ceo.address_more = @contact.address_more unless @ceo.address_more
      @ceo.city = @contact.city unless @ceo.city
      @ceo.state = @contact.state unless @ceo.state
      @ceo.postal_code = @contact.postal_code unless @ceo.postal_code
      @ceo.country_id = @contact.country_id unless @ceo.country
      
      # financial contact fields defaults to contact
      @financial_contact.address = @contact.address unless @financial_contact.address
      @financial_contact.address_more = @contact.address_more unless @financial_contact.address_more
      @financial_contact.city = @contact.city unless @financial_contact.city
      @financial_contact.state = @contact.state unless @financial_contact.state
      @financial_contact.postal_code = @contact.postal_code unless @financial_contact.postal_code
      @financial_contact.country_id = @contact.country_id unless @financial_contact.country
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
    end
    
    def new_contact(role)
      contact = Contact.new
      contact.role_ids = [role.id] if role
      contact
    end
        
    def extract_organization_type(organization)
      organization.business_entity? ? BUSINESS_PARAM : NONBUSINESS_PARAM
    end
end
