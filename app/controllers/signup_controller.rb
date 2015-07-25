class SignupController < Redesign::ApplicationController
  before_filter :load_organization_signup
  before_filter :load_page

  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  def index
    set_current_container_by_default_path
    @page = ArticlePage.new(current_container, current_payload_data)
    render "redesign/static/#{current_container.layout}"
  end

  # shows organization form
  def step1
    clear_organization_signup

    if @signup.organization.jci_referral? request.env["HTTP_REFERER"]
      session[:is_jci_referral] = true
      @jci_referral = true
    end
  end

  # POST from organization form
  # shows contact form
  def step2
    if request.post?
      @signup.set_organization_attributes(organization_params)
      @signup.set_registration_attributes(registration_params)

      store_organization_signup
    end

    if !@signup.valid?
      redirect_to organization_step1_path(:org_type => @signup.org_type)
    end
  end

  # POST from contact form
  # shows ceo form
  def step3
    if request.post?
      @signup.set_primary_contact_attributes(contact_params)
      store_organization_signup
    end

    @next_step = @signup.business? ? organization_step4_path : organization_step6_path

    if @signup.valid_primary_contact?
      @signup.prepare_ceo
    else
      redirect_to organization_step2_path
    end
  end

  # POST from ceo form
  # pledge form if business organization
  def step4
    if request.post?
      @signup.set_ceo_attributes(contact_params)
      store_organization_signup
    end

    unless @signup.valid_ceo?
      redirect_to organization_step3_path
    end

    # highlight amount by assigning CSS class
    @suggested_pledge_amount = {}
    @suggested_pledge_amount[@signup.organization.revenue] = 'highlight_suggested_amount'
  end

  # POST from pledge form
  # ask for financial contact if pledge was made
  def step5
    if request.post?
      @signup.set_pledge_attributes(pledge_params)
      @signup.prepare_financial_contact

      store_organization_signup
    end

    case
    when @signup.pledge_incomplete?
      redirect_to organization_step4_path
    when !@signup.require_pledge?
      redirect_to organization_step6_path
    else
      # render step5 form
    end
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  def step6
    # coming from step5, organization has selected a pledge amount
    if @signup.require_pledge?
      if request.post?
        @signup.set_financial_contact_attributes(contact_params) if contact_params
        store_organization_signup
      end

      if !@signup.financial_contact.valid? && !@signup.primary_contact.is?(Role.financial_contact)
        redirect_to organization_step5_path
      end
    # coming from step3 or 4
    else
      if request.post?
        @signup.set_ceo_attributes(contact_params) if contact_params
        store_organization_signup
      end

      unless @signup.valid_ceo?
        redirect_to organization_step3_path
      end
    end
  end

  # POST from commitment letter form
  # shows thank you page
  def step7
    if commitment_letter_params[:commitment_letter]
      @signup.set_commitment_letter_attributes(commitment_letter_params)
    end

    if @signup.complete_valid?
      @signup.save

      send_mail

      clear_organization_signup
      session[:is_jci_referral] = nil
    else
      @signup.organization.commitment_letter = nil
      redirect_to organization_step6_path
    end
  end

  private

    def load_page
      @page = SignupPage.new
    end

    def load_organization_signup
      @signup = session["signup"] || create_signup(params[:org_type])
    end

    def store_organization_signup
      session[:signup] = @signup
    end

    def clear_organization_signup
      session[:signup] = nil
    end

    def send_mail
      OrganizationMailer.submission_received(@signup.organization).deliver
      if session[:is_jci_referral]
        OrganizationMailer.submission_jci_referral_received(@signup.organization).deliver
      end
    rescue Exception
      flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
    end

    def create_signup(org_type)
      if org_type == NONBUSINESS_PARAM
        NonBusinessOrganizationSignup.new
      else
        BusinessOrganizationSignup.new
      end
    end

    def organization_params
      params.require(:organization).permit(
        :name,
        :url,
        :employees,
        :organization_type_id,
        :listing_status_id,
        :is_ft_500,
        :exchange_id,
        :stock_symbol,
        :isin,
        :sector_id,
        :revenue,
        :country_id,
        :legal_status
      )
    end

    def registration_params
      params.fetch(:non_business_organization_registration, {}).permit(
        :date,
        :place,
        :authority,
        :number,
        :legal_status
      )
    end

    def contact_params
      params.require(:contact).permit(
        :foundation_contact,
        :prefix,
        :first_name,
        :middle_name,
        :last_name,
        :job_title,
        :email,
        :phone,
        :address,
        :address_more,
        :city,
        :state,
        :postal_code,
        :country_id,
        :username,
        :password,
        :welcome_package
      )
    end

    def pledge_params
      params.require(:organization).permit(
        :pledge_amount,
        :no_pledge_reason
      )
    end

    def commitment_letter_params
      organization_params = params.fetch(:organization, {}).permit(:commitment_letter)
      non_business_params = params.fetch(:non_business_organization_registration, {})
      organization_params.merge(non_business_params)
    end
end
