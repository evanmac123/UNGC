class SignupController < ApplicationController
  helper 'Navigation'
  before_filter :load_objects

  def step1
    @organization.organization_type_id = @organization_types.first.id unless @organization.organization_type_id
  end
  
  def step2
    if params[:organization]
      @organization.attributes = params[:organization]
      session[:signup_organization] = @organization
    end
    
    unless @organization.valid?
      redirect_to organization_step1_path(:org_type => 'business') 
    else
      render :template => 'signup/sorry.html.haml' if @organization.employees < 10
    end
  end
  
  def step3
    if params[:contact]
      @contact.attributes = params[:contact]
      session[:signup_contact] = @contact
    end

    redirect_to organization_step2_path unless @contact.valid?
  end

  def step4
    if params[:contact]
      @ceo.attributes = params[:contact]
      session[:signup_ceo] = @ceo
    end

    redirect_to organization_step3_path unless @ceo.valid?
  end
  
  def step5
    @organization.attributes = params[:organization]
    if @organization.commitment_letter?
      # save all records
      @organization.save
      @organization.contacts << @contact
      @organization.contacts << @ceo
      clean_session
    else
      flash[:error] = 'Upload you commitment letter'
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
      @contact = session[:signup_contact] || Contact.new
      @ceo = session[:signup_ceo] || Contact.new
      # organization country is default for contacts
      @contact.country_id = @contact.country_id unless @contact.country
      @ceo.country_id = @organization.country_id unless @ceo.country
    end

    def load_organization_types
      method = ['business', 'non_business'].include?(params[:org_type]) ? params[:org_type] : 'business'
      @organization_types = OrganizationType.send method
    end
    
    def clean_session
      session[:signup_organization] = Organization.new
      session[:signup_contact] = Contact.new
      session[:signup_ceo] = Contact.new
    end
end
