class Admin::SigningsController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_initiative

  def create
    @signing = @initiative.signings.new(params[:signing])

    if @signing.save
      flash[:notice] = 'Signatory added.'
      redirect_to admin_initiative_path(@initiative)
    else
      render :action => "new"
    end
  end

  def destroy
    @signing = @initiative.signings.find(params[:id])
    @signing.destroy
    redirect_to admin_initiative_path(@initiative)
  end
  
  private
    def load_initiative
      @initiative = Initiative.find params[:initiative_id]
    end
end
