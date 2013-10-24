class Admin::CopsController < AdminController
  before_filter :load_organization, :except => :introduction
  before_filter :no_unapproved_organizations_access
  before_filter :set_session_template, :only => :new
  before_filter :only_editable_cops_go_to_edit, :only => :edit
  helper 'datetime'

  def introduction
    # non-business organizations can submit a COP, but they do not get a choice, so redirect them to the General (intermediate) COP
    # but we still want Global Compact Staff and Networks to choose the type of COP
    if current_contact.from_organization? && current_contact.organization.non_business?
      redirect_to new_admin_organization_communication_on_progress_path(current_contact.organization.id, :type_of_cop => 'non_business')
    end

    if current_contact.organization.signatory_of?(:lead)
      render 'lead_introduction'
    end

  end

  def new
    unless CommunicationOnProgress::TYPES.include?(session[:cop_template])
      redirect_to cop_introduction_path
    end

    @communication_on_progress = @organization.communication_on_progresses.new
    @communication_on_progress.init_cop_attributes
    @communication_on_progress.title = @organization.cop_name
    @cop_link_language = Language.for(:english).try(:id)
    @cop_file_language = Language.for(:english).try(:id)
    @submitted = false
  end

  def create
    @communication_on_progress = @organization.communication_on_progresses.new(params[:communication_on_progress])
    @communication_on_progress.type = session[:cop_template]
    @communication_on_progress.contact_name = params[:communication_on_progress][:contact_name] || current_contact.contact_info

    @communication_on_progress.cop_answers.each do |answer|
      answer.text = "" if answer.value == false && answer.text.present?
    end

    if @communication_on_progress.save
      flash[:notice] = "The COP has been published on the Global Compact website"
      clear_session_template
    else
      # we want to preselect the submit tab
      @submitted = true
      # web links are not included with Basic COPs and Grace Letters
      unless @communication_on_progress.type == 'basic' || @communication_on_progress.type == 'grace'
        @cop_link_url = params[:communication_on_progress][:cop_links_attributes][:new_cop][:url] || ''
        @cop_link_language = params[:communication_on_progress][:cop_links_attributes][:new_cop][:language_id] || Language.for(:english).id
      end
      render :action => "new"
      return
    end

    unless @communication_on_progress.is_grace_letter?
      begin
        CopMailer.send("confirmation_#{@communication_on_progress.confirmation_email}", @organization, @communication_on_progress, current_contact).deliver
      rescue Exception => e
        flash[:error] = 'Sorry, we could not send the confirmation email due to a server error.'
      end
    end

    redirect_to admin_organization_communication_on_progress_path(@communication_on_progress.organization.id, @communication_on_progress)

  end

  def show

    if @communication_on_progress.evaluated_for_differentiation?
      @cop_partial = "/shared/cops/show_#{@communication_on_progress.differentiation}_style"

      # Basic COP template has its own partial to display text responses
      if @communication_on_progress.is_basic?
        @results_partial = '/shared/cops/show_basic_style'
      else
        @results_partial = '/shared/cops/show_differentiation_style'
      end

    elsif @communication_on_progress.is_grace_letter?
      @cop_partial = '/shared/cops/show_grace_style'
    elsif @communication_on_progress.is_basic?
      @cop_partial = '/shared/cops/show_basic_style'
    elsif @communication_on_progress.is_non_business_format?
      @cop_partial = '/shared/cops/show_non_business_style'
    elsif @communication_on_progress.is_new_format?
      @cop_partial = '/shared/cops/show_new_style'
    elsif @communication_on_progress.is_legacy_format?
      @cop_partial = '/shared/cops/show_legacy_style'
    else
     flash[:error] = "Sorry, we could not determine the COP type."
     redirect_to admin_organization_path(org_id, :tab => :cops)
    end

  end

  def update
    @communication_on_progress.update_attributes(params[:communication_on_progress])
    redirect_to admin_organization_communication_on_progress_path(@organization.id, @communication_on_progress)
  end

  def destroy
    org_id = @communication_on_progress.organization.id
    if @communication_on_progress.destroy
      flash[:notice] = 'The COP was deleted'
    else
      flash[:error] =  @communication_on_progress.errors.full_messages.to_sentence
    end
   redirect_to admin_organization_path(org_id, :tab => :cops)
  end

  private

    def set_session_template
      session[:cop_template] = params[:type_of_cop]
    end

    def clear_session_template
      session[:cop_template] = nil
    end

    def load_organization
      @communication_on_progress = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end

    def only_editable_cops_go_to_edit
      unless @communication_on_progress.editable?
        flash[:notice] = "You cannot edit this COP"
        redirect_to admin_organization_path(@communication_on_progress.organization.id, :tab => :cops)
      end
    end
end
