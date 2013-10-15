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

    @os.step2(params[:organization])

    session[:os] = @os

    unless @os.organization.valid?
      redirect_to organization_step1_path(:org_type => @os.org_type)
    end
  end

  # POST from contact form
  # shows ceo form
  def step3
    load_session

    @os.step3(params[:contact])

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

    @os.step4(params[:contact])

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

    @os.step5(params[:organization])

    session[:os] = @os

    unless @os.organization.pledge_amount.to_i > 0
      redirect_to organization_step6_path
    end
  end

  # POST from ceo or financial contact form
  # shows commitment letter form
  def step6
    load_session

    # coming from 3 or 5 but not 7
    # XXX fix this
    if params[:contact]
      @os.step6(params[:contact])
    end

    session[:os] = @os

    # coming from step5
    # XXX could this bi @os.business??
    if @os.organization.pledge_amount.to_i > 0
      unless @os.financial_contact.valid? || @os.primary_contact.is?(Role.financial_contact)
        redirect_to organization_step5_path
      end
    end

    # coming from step3
    unless @os.ceo.valid? and @os.unique_emails?
      redirect_to organization_step3_path
    end
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


  def step7
    load_session

    @os.step7(params[:organization])


    if @os.organization.valid? && @os.organization.commitment_letter?
      raise @os.inspect.to_s
      raise "ADD SAVE ACTIONS"
      raise "ADD EMAIL"
      raise "CLEAN SESSOIN"
    else
      flash[:error] = "Please upload your Letter of Commitment. #{@os.organization.errors.full_messages.to_sentence}"
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
