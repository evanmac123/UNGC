class Admin::GraceLettersController < AdminController
  before_filter :load_letter_and_organization
  before_filter :no_unapproved_organizations_access

  def show
    @grace_letter = GraceLetterPresenter.new(@letter, current_contact)
  end

  def new
    @letter = @organization.communication_on_progresses.new
    @letter.init_cop_attributes
    @letter.title = @organization.cop_name
    @letter.type = 'grace'

    # TODO move these to a form object? not needed for a grace letter?
    @cop_link_language = Language.for(:english).try(:id)
    @cop_file_language = Language.for(:english).try(:id)

    # used to preselect the tab, move to form object?
    # can we delete this?
    @submitted = false
  end

  def edit
    unless @letter.editable?
      flash[:notice] = "You cannot edit this grace letter"
      redirect_to admin_organization_url(@organization.id, :tab => :cops)
    end
  end

  def create
    @letter = @organization.communication_on_progresses.new(params[:grace_letter])
    @letter.type = 'grace'

    if @letter.save
      # TODO add a more appropriate message
      flash[:notice] = "The grace letter has been published on the Global Compact website"
      redirect_to admin_organization_grace_letters_url(@organization.id, @letter)
    else
      # we want to preselect the submit tab
      # move to form object
      @submitted = true # is this still needed?
      render :new
    end
  end

  def update
    @letter.update_attributes(params[:grace_letter])
    redirect_to admin_organization_grace_letters_url(@organization.id, @letter)
  end

  def destroy
    org_id = @letter.organization.id
    if @letter.destroy
      flash[:notice] = 'The grace letter was deleted'
    else
      flash[:error] =  @letter.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_url(org_id, :tab => :cops)
  end

  private

    def load_letter_and_organization
      @letter = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
