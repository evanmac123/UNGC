class Admin::SigningsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_initiative

  def create
    @signing = @initiative.signings.new(params[:signing])

    if @signing.save
      flash[:notice] = 'Signatory added.'
    else
      flash[:error] = 'Signatory could not be added. That organization may already be in the list.'
    end

    redirect_to admin_initiative_path(@initiative)
  end

  def destroy
    @signing = @initiative.signings.find(params[:id])
    @signing.destroy
    flash[:notice] = 'Signatory was removed.'
    redirect_to admin_initiative_path(@initiative)
  end

  private
    def load_initiative
      @initiative = Initiative.find params[:initiative_id]
    end
end
