class SignupController < ApplicationController
  before_filter :determine_navigation

  BUSINESS_PARAM = 'business'
  NONBUSINESS_PARAM = 'non_business'

  # shows organization form
  def step1
    load_session

    @organization_types = OrganizationType.send @os.org_type

    session[:os] = nil

    if @os.organization.jci_referral? request.env["HTTP_REFERER"]
      session[:is_jci_referral] = true
      @jci_referral = true
    end
  end

  # POST from organization form
  # shows contact form
  def step2
    load_session

    @os.set_organization_attributes(params[:organization])

    session[:os] = @os

    unless @os.organization.valid?
      redirect_to organization_step1_path(:org_type => @os.org_type)
    end
  end

  # POST from contact form
  # shows ceo form
  def step3
    load_session

    @os.set_primary_contact_attributes_and_prepare_ceo(params[:contact])

    session[:os] = @os

    @next_step = @os.business? ? organization_step4_path : organization_step6_path

    unless @os.primary_contact.valid?
      redirect_to organization_step2_path
    end
  end

  # POST from ceo form
  # pledge form if business organization
  def step4
    load_session

    @os.set_ceo_attributes(params[:contact])

    session[:os] = @os

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
    load_session

    @os.set_organization_attributes(params[:organization])
    @os.prepare_financial_contact

    session[:os] = @os

    unless @os.organization.pledge_amount.to_i > 0
      redirect_to organization_step6_path
    end
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  def step6
    load_session

    # coming from step5, organization is gonna give a pledge
    if @os.organization.pledge_amount.to_i > 0
      @os.set_financial_contact_attributes(params[:contact]) if params[:contact]
      session[:os] = @os
      unless @os.financial_contact.valid? || @os.primary_contact.is?(Role.financial_contact)
        redirect_to organization_step5_path
      end
    # coming from step3 or 4
    else
      @os.set_ceo_attributes(params[:contact]) if params[:contact]
      session[:os] = @os
      unless @os.ceo.valid? and @os.unique_emails?
        redirect_to organization_step3_path
      end
    end
  end

  # POST from commitment letter form
  # shows thank you page
  def step7
    load_session

    @os.set_organization_attributes(params[:organization])

    if @os.organization.valid? && @os.organization.commitment_letter?
      # save all records
      @os.organization.save
      @os.primary_contact.save
      @os.ceo.save
      @os.organization.contacts << @os.primary_contact
      @os.organization.contacts << @os.ceo

      # add financial contact if a pledge was made and the existing contact has not been assigned that role
      unless @os.organization.pledge_amount.blank? and @os.primary_contact.is?(Role.financial_contact)
        @os.financial_contact.save
        @os.organization.contacts << @os.financial_contact
      end


      session[:os] = nil
      session[:is_jci_referral] = nil
      begin
        OrganizationMailer.submission_received(@os.organization).deliver
        if session[:is_jci_referral]
          OrganizationMailer.submission_jci_referral_received(@os.organization).deliver
        end
      rescue Exception => e
       flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end
    else
      flash[:error] = "Please upload your Letter of Commitment. #{@os.organization.errors.full_messages.to_sentence}"
      @os.organization.commitment_letter = nil
      redirect_to organization_step6_path
    end
  end

  private

    def load_session
      @os = session[:os] || OrganizationSignup.new(params[:org_type])
    end

    def default_navigation
      DEFAULTS[:signup_form_path]
    end

end
