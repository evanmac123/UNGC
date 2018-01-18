class SignupController < ApplicationController
  before_filter :load_organization_signup
  before_filter :load_page

  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  def index
    set_current_container_by_default_path
    @page = ArticlePage.new(current_container, current_payload_data)
    render "static/#{current_container.layout}"
  end

  # shows organization form
  # posts to step2
  def step1
    clear_organization_signup

    @sectors = SectorTree.load

    if @signup.organization.jci_referral? request.env["HTTP_REFERER"]
      session[:is_jci_referral] = true
      @jci_referral = true
    end
  end

  # POST from organization form
  # shows contact form
  # posts to step3
  def step2
    if request.post?
      # Accept input from step1
      @signup.set_organization_attributes(organization_params)
      @signup.set_registration_attributes(registration_params)

      store_organization_signup
    end

    if !@signup.valid?
      flash[:error] = @signup.error_messages
      redirect_to organization_step1_path(:org_type => @signup.org_type)
    end
  end

  # POST from contact form
  # shows ceo form
  # posts to step4 for businesses
  # posts to step6 for non-businesses
  def step3
    if request.post?
      @signup.set_primary_contact_attributes(contact_params)
      store_organization_signup
    end

    @next_step = @signup.business? ? organization_step4_path : organization_step6_path

    if @signup.valid_primary_contact?
      @signup.prefill_ceo_contact_info
    else
      # There was a problem with step2, send them back
      flash[:error] = @signup.error_messages
      redirect_to organization_step2_path
    end
  end

  # POST from ceo form
  # pledge form if business organization
  # posts to step5
  def step4
    handle_ceo_attributes()
  end

  # POST from pledge form
  # ask for financial contact info
  # posts to step6
  def step5
    if request.post?
      @signup.select_participation_level(participation_level_params)
      @signup.prefill_financial_contact_address

      store_organization_signup
    end

    if !@signup.valid_participant_level? || !@signup.valid_action_platform_subscriptions?
      flash[:error] = @signup.error_messages
      redirect_to organization_step4_path
    end
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  # posts to step7
  def step6
    if @signup.business?
      if request.post?
        @signup.organization.invoice_date = params.fetch(:organization, {}).fetch(:invoice_date, nil)
        @signup.set_financial_contact_attributes(contact_params)
        store_organization_signup
      end

      if !@signup.financial_contact_valid? || !@signup.valid_invoice_date?
        flash[:error] = @signup.error_messages
        redirect_to organization_step5_path
      end
    else
      handle_ceo_attributes
    end
  end

  # POST from commitment letter form
  # shows thank you page
  def step7
    if request.post?
      @signup.set_commitment_letter_attributes(commitment_letter_params)
    end

    if @signup.complete_valid?
      @signup.save
      send_mail
      clear_organization_signup
      session[:is_jci_referral] = nil
    else
      @signup.organization.commitment_letter = nil
      flash[:error] = @signup.error_messages
      redirect_to organization_step6_path
    end
  end

  private

  def handle_ceo_attributes()
    if request.post?
      @signup.set_ceo_attributes(contact_params)
      store_organization_signup
    end

    unless @signup.valid_ceo?
      flash[:error] = @signup.error_messages
      redirect_to organization_step3_path
    end
  end

  def load_page
    @page = SignupPage.new
  end

  def load_organization_signup
    @signup = pending_signups.load || create_signup(params[:org_type])
  end

  def store_organization_signup
    pending_signups.store(@signup)
  end

  def clear_organization_signup
    pending_signups.clear
  end

  def pending_signups
    # HACK: ensure there is a session started
    session[:signup_session_hack] = true
    PendingSignup.new(session.id)
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
      :precise_revenue,
      :country_id,
      :legal_status,
      :is_subsidiary,
      :parent_company_id,
      :is_tobacco,
      :is_landmine,
      :is_biological_weapons,
      :parent_company_name,
      :parent_company_id
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
      :role_ids => []
    )
  end

  def commitment_letter_params
    organization_params = params.fetch(:organization, {}).permit(:commitment_letter)
    non_business_params = params.fetch(:non_business_organization_registration, {})
    organization_params.merge(non_business_params)
  end

  def participation_level_params
    params.require(:organization).permit(
      :level_of_participation,
      :invoice_date,
      subscriptions: [
        :selected,
        :contact_id,
        :platform_id
      ]
    )
  end
end
