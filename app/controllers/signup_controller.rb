class SignupController < ApplicationController
  before_filter :determine_navigation, :load_organization_signup

  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  # shows organization form
  def step1
    # XXX fix this
    @organization_types = OrganizationType.send (@os.org_type || params[:org_type])

    clear_organization_signup

    if @os.organization.jci_referral? request.env["HTTP_REFERER"]
      session[:is_jci_referral] = true
      @jci_referral = true
    end
  end

  # POST from organization form
  # shows contact form
  def step2
    @os.set_organization_attributes(params[:organization], params[:non_business_organization_registration])

    store_organization_signup

    if !@os.organization.valid?
      redirect_to organization_step1_path(:org_type => @os.org_type)
    end
  end

  # POST from contact form
  # shows ceo form
  def step3
    @os.set_primary_contact_attributes(params[:contact])
    @os.prepare_ceo

    store_organization_signup

    @next_step = @os.business? ? organization_step4_path : organization_step6_path

    unless @os.primary_contact.valid?
      redirect_to organization_step2_path
    end
  end

  # POST from ceo form
  # pledge form if business organization
  def step4
    @os.set_ceo_attributes(params[:contact])

    store_organization_signup

    unless @os.ceo.valid? and @os.unique_emails?
      redirect_to organization_step3_path
    end

    # highlight amount by assigning CSS class
    @suggested_pledge_amount = {}
    @suggested_pledge_amount[@os.organization.revenue] = 'highlight_suggested_amount'
    # preselect radio button
    @checked_pledge_amount = {}
    @checked_pledge_amount[@os.organization.revenue] = true
  end

  # POST from pledge form
  # ask for financial contact if pledge was made
  def step5
    @os.set_organization_attributes(params[:organization])
    @os.prepare_financial_contact

    store_organization_signup

    unless @os.organization.pledge_amount.to_i > 0
      redirect_to organization_step6_path
    end
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  def step6
    # coming from step5, organization is gonna give a pledge
    if @os.organization.pledge_amount.to_i > 0
      @os.set_financial_contact_attributes(params[:contact]) if params[:contact]
      store_organization_signup
      unless @os.financial_contact.valid? || @os.primary_contact.is?(Role.financial_contact)
        redirect_to organization_step5_path
      end
    # coming from step3 or 4
    else
      @os.set_ceo_attributes(params[:contact]) if params[:contact]
      store_organization_signup
      unless @os.ceo.valid? and @os.unique_emails?
        redirect_to organization_step3_path
      end
    end
  end

  # POST from commitment letter form
  # shows thank you page
  def step7
    @os.set_organization_attributes(params[:organization], params[:non_business_organization_registration])

    if @os.valid_organization? && @os.organization.commitment_letter?
      @os.save

      send_mail

      clear_organization_signup
      session[:is_jci_referral] = nil
    else
      message = ''
      if !@os.organization.commitment_letter?
        message = "Please upload your Letter of Commitment."
      end
      flash[:error] = message + "#{@os.organization.errors.full_messages.to_sentence}, #{@os.registration.errors.full_messages.to_sentence}"
      @os.organization.commitment_letter = nil
      redirect_to organization_step6_path
    end
  end

  private

    def load_organization_signup
      @os = session[:os] || OrganizationSignup.new(params[:org_type])
    end

    def store_organization_signup
      session[:os] = @os
    end

    def clear_organization_signup
      session[:os] = nil
    end

    def default_navigation
      DEFAULTS[:signup_form_path]
    end

    def send_mail
      begin
        OrganizationMailer.submission_received(@os.organization).deliver
        if session[:is_jci_referral]
          OrganizationMailer.submission_jci_referral_received(@os.organization).deliver
        end
      rescue Exception => e
       flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end
    end
end
