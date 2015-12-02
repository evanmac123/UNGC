class Admin::CopsController < AdminController
  before_filter :load_organization, except: [:introduction, :edit_draft]
  before_filter :no_unapproved_organizations_access
  before_filter :cop_update_policy, only: [:update]
  before_filter :no_organization_or_local_network_access, only: [:edit, :backdate, :do_backdate]
  helper :datetime

  def introduction
    if current_contact.from_organization? && current_contact.organization.non_business?
      render :non_business_introduction
    elsif current_contact.organization.signatory_of?(:lead)
      render :lead_introduction
    else
      render :introduction
    end
  end

  def show
    @communication = CommunicationPresenter.create(@cop, current_contact)
  end

  def new
    # show the COP form (basic/grace/RCA/intermediate/advanced) for a new COP
    # TODO resume an existing COP draft
    # TODO clean up stale drafts
    unless CommunicationOnProgress::TYPES.include?(cop_type)
      redirect_to cop_introduction_url
    end

    @communication_on_progress = CopForm.new_form(@organization, cop_type, current_contact.contact_info)
    @communication_on_progress.build_cop_answers
  end

  def edit
    # UNGC staff is editing a submitted COP
    if @cop.editable?
      @communication_on_progress = create_edit_cop_form(@cop)
    else
      flash[:notice] = "You cannot edit this COP"
      redirect_to admin_organization_url(@cop.organization, tab: :cops)
    end
  end

  def edit_draft
    # an organization user is editing an existing draft
    @organization = current_contact.organization
    cop = @organization.communication_on_progresses.in_progress.find(params.fetch(:id))
    @communication_on_progress = create_edit_cop_form(cop)
  end

  def create
    @communication_on_progress = CopForm.new_form(@organization, cop_params.fetch(:cop_type), current_contact.contact_info)
    if saving_draft?
      create_draft(@communication_on_progress)
    else
      create_published(@communication_on_progress)
    end
  end

  def update
    @communication_on_progress = create_edit_cop_form(@cop)
    case
    when current_contact.from_ungc?
      # ungc staff updating a completed COP
      staff_update_cop(@communication_on_progress)
    when saving_draft?
      # an organization user updating an existing draft
      update_draft(@communication_on_progress)
    else
      # an organization user publishing a draft
      publish_draft(@communication_on_progress)
    end
  end

  def destroy
    # ungc staff is destroying a COP
    # TODO an organization user is discarding a Draft
    org_id = @cop.organization.id
    if @cop.destroy
      flash[:notice] = 'The communication was deleted'
    else
      flash[:error] = @cop.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_url(org_id, tab: :cops)
  end

  def backdate
    # show the backdate form
  end

  def do_backdate
    # handle the backdate POST
    published_on = Time.parse(params[:published_on]).to_date
    if BackdateCommunicationOnProgress.backdate(@cop, published_on)
      flash[:notice] = 'The communication was backdated'
      redirect_to admin_organization_communication_on_progress_url(@organization.id, @cop, tab: :results)
    else
      flash[:error] = 'Sorry, we could not backdate the communication'
      render :backdate
    end
  end

  private

    def cop_update_policy
      # TODO only ungc and current org IF cop is in draft
      true
    end

    def saving_draft?
      params.fetch(:saving_draft, false)
    end

    def create_draft(form)
      if form.save_draft(cop_params)
        flash[:notice] = "The communication draft has been saved"
        redirect_to edit_draft_admin_organization_communication_on_progress_url(@organization.id, form.cop)
      else
        render :new
      end
    end

    def create_published(form)
      if form.submit(cop_params)
        flash[:notice] = "The communication has been published on the Global Compact website"
        send_cop_submission_confirmation_email(form.cop)
        redirect_to admin_organization_communication_on_progress_url(@organization.id, form.cop)
      else
        render :new
      end
    end

    def update_draft(form)
      if form.save_draft(cop_params)
        flash[:notice] = "The communication draft has been saved"
        redirect_to edit_draft_admin_organization_communication_on_progress_url(@organization.id, form.cop)
      else
        render :edit
      end
    end

    def publish_draft(form)
      if form.submit(cop_params)
        flash[:notice] = "The communication has been published on the Global Compact website"
        send_cop_submission_confirmation_email(form.cop)
        redirect_to admin_organization_communication_on_progress_url(@organization.id, form.cop)
      else
        render :edit
      end
    end

    def staff_update_cop(form)
      # XXX the check for editable should be done in a policy object and probably in the before filter
      unless @cop.editable?
        redirect_to admin_organization_url(@cop.organization, tab: :cops)
        return
      end

      if form.update(cop_params)
        flash[:notice] = "The communication was updated"
        redirect_to admin_organization_communication_on_progress_url(@organization.id, @cop, tab: :results)
      else
        render :edit
      end
    end

    def create_edit_cop_form(cop)
      CopForm.edit_form(cop, current_contact.contact_info)
    end

    def send_cop_submission_confirmation_email(cop)
      begin
        CopMailer.delay.public_send("confirmation_#{cop.confirmation_email}", @organization, cop, current_contact)
      rescue Exception
        flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end
    end

    def cop_type
      params[:type_of_cop]
    end

    def cop_params
      params.require(:communication_on_progress).permit(
        :cop_type,
        :title,
        :references_human_rights,
        :references_labour,
        :references_environment,
        :references_anti_corruption,
        :include_measurement,
        :include_continued_support_statement,
        :starts_on,
        :ends_on,
        :differentiation,
        :format,
        :method_shared,
        cop_files_attributes: [
          :attachment_type,
          :language_id,
          :attachment
        ],
        cop_answers_attributes: [
          :cop_attribute_id,
          :text,
          :value
        ],
        cop_links_attributes: [
          :url,
          :language_id,
          :id,
          :attachment_type,
          :_destroy,
          {
            new_cop: [
              :attachment_type,
              :language_id,
              :url
            ]
          }
        ]
      )
    end

    def load_organization
      @cop = CommunicationOnProgress.unscoped.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
