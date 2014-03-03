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
      redirect_to admin_organization_reporting_cycle_adjustment_url(@organization.id, @form.reporting_cycle_adjustment)
    else
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
      redirect_to admin_organization_reporting_cycle_adjustment_url(@organization.id, @form.reporting_cycle_adjustment)
    else
      render :edit
    end
  end


  private
    def load_adjustment_and_organization
      @adjustment = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end

    def reporting_cycle_adjustment_params
      params[:reporting_cycle_adjustment]
    end
end
