class Admin::GraceLettersController < AdminController
  before_filter :load_letter_and_organization
  before_filter :no_unapproved_organizations_access
  before_filter :no_organization_or_local_network_access, only: [:edit, :update]

  def show
    @grace_letter = GraceLetterPresenter.new(@letter, current_contact)
  end

  def new
    if GraceLetterApplication.eligible?(@organization)
      @form = GraceLetterForm.new(@organization)
    else
      flash[:notice] = "You cannot submit a grace letter at this time"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def edit
    if @letter.editable?
      @form = GraceLetterForm.new(@organization, @letter)
    else
      flash[:notice] = "You cannot edit this grace letter"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def create
    @form = GraceLetterForm.new(@organization)
    if @form.submit(grace_letter_params)
      flash[:notice] = "The grace letter has been published on the Global Compact website"
      redirect_to admin_organization_grace_letter_url(@organization.id, @form.grace_letter)
    else
      render :new
    end
  end

  def update
    @form = GraceLetterForm.new(@organization, @letter)
    if @form.update(grace_letter_params)
      redirect_to admin_organization_grace_letter_url(@organization.id, @form.grace_letter)
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

    def grace_letter_params
      params[:grace_letter]
    end
end
