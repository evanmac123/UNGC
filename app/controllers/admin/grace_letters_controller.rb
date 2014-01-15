class Admin::GraceLettersController < AdminController
  before_filter :load_letter_and_organization
  before_filter :no_unapproved_organizations_access

  def show
    @grace_letter = GraceLetterPresenter.new(@letter, current_contact)
  end

  def new
    @grace_letter = GraceLetterForm.new(organization: @organization)

    unless @grace_letter.can_submit?
      flash[:notice] = "You cannot submit a grace letter"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def edit
    @grace_letter = GraceLetterForm.new(organization: @organization, grace_letter: @letter)

    unless @grace_letter.editable?
      flash[:notice] = "You cannot edit this grace letter"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def create
    @grace_letter = GraceLetterForm.new(
      organization: @organization,
      params: params[:communication_on_progress]
    )

    if @grace_letter.save
      flash[:notice] = "The grace letter has been published on the Global Compact website"
      redirect_to admin_organization_grace_letter_url(@organization.id, @grace_letter.id)
    else
      render :new
    end
  end

  def update
    @grace_letter = GraceLetterForm.new(
      organization: @organization,
      grace_letter: @letter,
      params: params[:communication_on_progress]
    )

    if @grace_letter.save
      redirect_to admin_organization_grace_letter_url(@organization.id, @grace_letter.id)
    else
      render :edit
    end
  end

  def destroy
    org_id = @letter.organization.id
    if @letter.destroy
      flash[:notice] = 'The grace letter was deleted'
    else
      flash[:error] = @letter.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_url(org_id, tab: :cops)
  end

  private

    def load_letter_and_organization
      @letter = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
