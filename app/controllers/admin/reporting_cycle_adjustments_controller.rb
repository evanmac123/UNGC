class Admin::ReportingCycleAdjustmentsController < AdminController
  before_filter :load_adjustment_and_organization
  before_filter :no_organization_or_local_network_access, only: [:edit, :update]

  def show
    @cycle_adjustment = ReportingCycleAdjustmentPresenter.new(@adjustment, current_contact)
  end

  def new
    if ReportingCycleAdjustmentApplication.eligible?(@organization)
      @form = ReportingCycleAdjustmentForm.new(@organization)
    else
      flash[:notice] = "You can only submit one reporting cycle adjustment"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def create
    @form = ReportingCycleAdjustmentForm.new(@organization)
    if @form.submit(reporting_cycle_adjustment_params)
      flash[:notice] = "The Reporting Cycle Adjustment has been published on the Global Compact website"
      log_event :create, :ok
      redirect_to admin_organization_reporting_cycle_adjustment_url(@organization.id, @form.reporting_cycle_adjustment)
    else
      log_event :create, :fail, @form.errors
      render :new
    end
  end

  def edit
    if @adjustment.editable? #always true ATM
      @form = ReportingCycleAdjustmentForm.new(@organization, @adjustment)
      @form.edit = true
    else
      flash[:notice] = "You cannot edit this reporting cycle adjustment"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def update
    @form = ReportingCycleAdjustmentForm.new(@organization, @adjustment)
    if @form.update(reporting_cycle_adjustment_params)
      log_event :update, :ok
      redirect_to admin_organization_reporting_cycle_adjustment_url(@organization.id, @form.reporting_cycle_adjustment)
    else
      log_event :update, :fail, @form.errors
      render :edit
    end
  end

  def destroy
    org_id = @adjustment.organization.id
    if @adjustment.destroy
      flash[:notice] = 'The reporting cycle adjustment was deleted'
      log_event :destroy, :ok
    else
      flash[:error] = @adjustment.errors.full_messages.to_sentence
      log_event :destroy, :fail, @adjustment.errors
    end
    redirect_to admin_organization_url(org_id, tab: :cops)
  end

  private
    def load_adjustment_and_organization
      if id = params[:id]
        @adjustment = CommunicationOnProgress.visible_to(current_contact).find(id)
      end
      @organization = Organization.find params[:organization_id]
    end

    def reporting_cycle_adjustment_params
      params[:reporting_cycle_adjustment]
    end

    def log_event(event, status, errors = nil)
      CopAuditLog.log(
        event: event,
        type: :reporting_cycle_adjustment,
        status: status,
        errors: errors.try!(:full_messages) || [],
        contact: current_contact,
        organization: @organization,
        params: params
      )
    end
end
