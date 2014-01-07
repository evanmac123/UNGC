class Admin::CopsController < AdminController
  before_filter :load_organization, except: :introduction
  before_filter :set_session_template, only: :new
  before_filter :no_unapproved_organizations_access
  before_filter :ensure_valid_type, only: :new
  helper :datetime

  def introduction
    # non-business organizations can submit a COP, but they do not get a choice, so redirect them to the General (intermediate) COP
    # but we still want Global Compact Staff and Networks to choose the type of COP
    if current_contact.from_organization? && current_contact.organization.non_business?
      # TODO redirect to the (new) COE controller?
      redirect_to new_admin_organization_communication_on_progress_path(current_contact.organization.id, :type_of_cop => 'non_business')
    end

    # TODO fix lead_intrduction view (grace)
    if current_contact.organization.signatory_of?(:lead)
      render 'lead_introduction'
    end
  end

  def coe
    # TODO move to it's own controller
    @coe = @organization.communication_on_progresses.new
    @coe.type = 'non_business'
    render :coe
  end

  def new
    @communication_on_progress = @organization.communication_on_progresses.new
    @communication_on_progress.init_cop_attributes
    @communication_on_progress.title = @organization.cop_name
    @communication_on_progress.type = type_of_cop

    # TODO move these to a form object?
    @cop_link_language = Language.for(:english).try(:id)
    @cop_file_language = Language.for(:english).try(:id)

    # used to preselect the tab, move to form object?
    @submitted = false
  end

  def edit
    unless @communication_on_progress.editable?
      flash[:notice] = "You cannot edit this COP"
      redirect_to admin_organization_path(@communication_on_progress.organization.id, :tab => :cops)
    end
  end

  def create
    # TODO move type_of_cop to a hidden field in the form object
    @communication_on_progress = @organization.communication_on_progresses.new(params[:communication_on_progress])
    @communication_on_progress.type = session[:cop_template]
    @communication_on_progress.contact_name = params[:communication_on_progress][:contact_name] || current_contact.contact_info

    # TODO move this to a view concern on the way out?
    @communication_on_progress.cop_answers.each do |answer|
      answer.text = "" if answer.value == false && answer.text.present?
    end

    if @communication_on_progress.save
      flash[:notice] = "The communication has been published on the Global Compact website"
      clear_session_template

      # TODO move this to a service object?
      # is a form object AND a service overkill? feels like it.
      unless @communication_on_progress.is_grace_letter?
        begin
          CopMailer.send("confirmation_#{@communication_on_progress.confirmation_email}", @organization, @communication_on_progress, current_contact).deliver
        rescue Exception
          flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
        end
      end
      redirect_to admin_organization_communication_on_progress_path(@communication_on_progress.organization.id, @communication_on_progress)
    else
      # we want to preselect the submit tab
      # move to form object
      @submitted = true
      # web links are not included with Basic COPs and Grace Letters
      # TODO moving grace letters out to it's own controlller solves one part of this problem.
      # as for basic COPs... i'll punt for the moment.
      unless @communication_on_progress.type == 'basic' || @communication_on_progress.type == 'grace'
        @cop_link_url = params[:communication_on_progress][:cop_links_attributes][:new_cop][:url] || ''
        @cop_link_language = params[:communication_on_progress][:cop_links_attributes][:new_cop][:language_id] || Language.for(:english).id
      end
      render :new
    end
  end

  def show
    # by moving grace letters, coe and cycle adjustments out to their own controllers
    # we can remove some of the complexity of the CopPresenter hierarchy.
    @communication = CommunicationPresenter.create(@communication_on_progress, current_contact)
  rescue CopPresenter::InvalidCopTypeError
    flash[:error] = "Sorry, we could not determine the COP type."
    redirect_to admin_organization_path(@communication_on_progress.organization, :tab => :cops)
  end

  def update
    @communication_on_progress.update_attributes(params[:communication_on_progress])
    redirect_to admin_organization_communication_on_progress_path(@organization.id, @communication_on_progress)
  end

  def destroy
    org_id = @communication_on_progress.organization.id
    if @communication_on_progress.destroy
      flash[:notice] = 'The communication was deleted'
    else
      flash[:error] =  @communication_on_progress.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_path(org_id, :tab => :cops)
  end

  private

    # remove
    def set_session_template
      session[:cop_template] = params[:type_of_cop]
    end

    def clear_session_template
      session[:cop_template] = nil
    end

    def type_of_cop
      session[:cop_template]
    end

    def load_organization
      # load_organization also seems to load cop... hehe
      @communication_on_progress = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end

    def ensure_valid_type
      unless CommunicationOnProgress::TYPES.include?(type_of_cop)
        redirect_to cop_introduction_path
      end
    end
end
