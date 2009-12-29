class SignupController < ApplicationController
  before_filter :load_objects
  
  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  # shows organization form
  def step1
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

    redirect_to organization_step2_path unless @contact.valid?
  end

  # POST from ceo form
  # shows commitment letter/pledge form
  def step4
    if params[:contact]
      @ceo.attributes = params[:contact]
      session[:signup_ceo] = @ceo
    end

    redirect_to organization_step3_path unless @ceo.valid?
  end
  
  # POST from commitment letter/pledge form
  # shows thank you page
  def step5
    @organization.attributes = params[:organization]
    if @organization.valid? && @organization.commitment_letter?
      # save all records
      @organization.save
      @contact.save
      @ceo.save
      @organization.contacts << @contact
      @organization.contacts << @ceo
      
      deliver_notification_email(@organization)
      clean_session
    else
      flash[:error] = "Please upload your Letter of Commitment. #{@organization.errors.full_messages.to_sentence}"
      redirect_to organization_step4_path
    end
  end
  
  def no_session
    clean_session
    redirect_to organization_step1_path(:org_type => 'business')
  end

  private
    def load_objects
      @organization = session[:signup_organization] || Organization.new
      load_organization_types
      @contact = session[:signup_contact] || new_contact(Role.contact_point)
      @ceo = session[:signup_ceo] || new_contact(Role.ceo)
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
    
    def deliver_notification_email(organization)
      if organization.micro_enterprise?
        OrganizationMailer.deliver_reject_microenterprise(organization)
      else
        OrganizationMailer.deliver_submission_received(organization)
      end
    end
    
    def extract_organization_type(organization)
      organization.business_entity? ? BUSINESS_PARAM : NONBUSINESS_PARAM
    end
end
