class Admin::ReportingCycleAdjustmentsController < AdminController
  before_filter :load_adjustment_and_organization

  def show
    @cycle_adjustment = ReportingCycleAdjustmentPresenter.new(@adjustment, current_contact)
  end

  def new
    @cycle_adjustment = ReportingCycleAdjustmentForm.new(organization: @organization)

    unless @cycle_adjustment.can_submit?
      flash[:notice] = "You cannot submit a reporting cycle adjustment"
      redirect_to admin_organization_url(@organization.id, tab: :cops)
    end
  end

  def create
    @cycle_adjustment = ReportingCycleAdjustmentForm.new(
      organization: @organization,
      params: params[:communication_on_progress]
    )

    if @cycle_adjustment.save
      flash[:notice] = "The Reporting Cycle Adjustment has been published on the Global Compact website"
      redirect_to admin_organization_reporting_cycle_adjustment_url(@organization.id, @cycle_adjustment.id)
    else
      render :new
    end
  end


  private
    def load_adjustment_and_organization
      @adjustment = CommunicationOnProgress.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
