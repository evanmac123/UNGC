class Admin::CopsController < AdminController
  before_filter :load_organization, except: :introduction
  before_filter :no_unapproved_organizations_access
  before_filter :no_organization_or_local_network_access, only: [:edit, :update, :backdate, :do_backdate]
  before_filter :ensure_valid_type, only: :new
  helper :datetime

  def introduction
    if current_contact.from_organization? && current_contact.organization.non_business?
      render :non_business_introduction
    elsif current_contact.organization.signatory_of?(:lead)
      render :lead_introduction
    end
  end

  def show
    @communication = CommunicationPresenter.create(@cop, current_contact)
  end

  def new
    @communication_on_progress = CopForm.new_form(@organization, cop_type, current_contact.contact_info)
    @communication_on_progress.build_cop_answers
  end

  def edit
    if @cop.editable?
      @communication_on_progress = create_edit_cop_form(@cop)
    else
      flash[:notice] = "You cannot edit this COP"
      redirect_to admin_organization_url(@cop.organization, tab: :cops)
    end
  end

  def create
    @communication_on_progress = CopForm.new_form(@organization, cop_params[:cop_type], current_contact.contact_info)
    if @communication_on_progress.submit(cop_params)
      flash[:notice] = "The communication has been published on the Global Compact website"
      send_cop_submission_confirmation_email(@communication_on_progress.cop)
      redirect_to admin_organization_communication_on_progress_url(@organization.id, @communication_on_progress.cop)
    else
      render :new
    end
  end

  def update
    @communication_on_progress = create_edit_cop_form(@cop)

    # XXX the check for editable should be done in a policy object and probably in the before filter
    unless @cop.editable?
      redirect_to admin_organization_url(@cop.organization, tab: :cops)
      return
    end

    if @communication_on_progress.update(cop_params)
      redirect_to admin_organization_communication_on_progress_url(@organization.id, @cop, tab: 'results')
    else
      render :edit
    end
  end

  def destroy
    org_id = @cop.organization.id
    if @cop.destroy
      flash[:notice] = 'The communication was deleted'
    else
      flash[:error] = @cop.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_url(org_id, tab: :cops)
  end

  def backdate
  end

  def do_backdate
    published_on = Time.parse(params[:published_on]).to_date
    if BackdateCommunicationOnProgress.backdate(@cop, published_on)
      redirect_to admin_organization_communication_on_progress_url(@organization.id, @cop)
    else
      flash[:error] = 'Sorry, we could not update the published_on date.'
      render :backdate
    end
  end

  private

    def create_edit_cop_form(cop)
      CopForm.edit_form(cop, current_contact.contact_info)
    end

    def send_cop_submission_confirmation_email(cop)
      begin
        CopMailer.send("confirmation_#{cop.confirmation_email}", @organization, cop, current_contact).deliver
      rescue Exception
        flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end
    end

    def cop_type
      params[:type_of_cop]
    end

    def cop_params
      params[:communication_on_progress]
    end

    def load_organization
      @cop = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end

    def ensure_valid_type
      unless CommunicationOnProgress::TYPES.include?(cop_type)
        redirect_to cop_introduction_url
      end
    end
end
