class Admin::InitiativesController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_initiative

  def index
    @initiatives = Initiative.all
  end

  def new
    @initiative = Initiative.new
  end

  def create
    @initiative = Initiative.new(initiative_params)

    if @initiative.save
      flash[:notice] = 'Initiative created.'
      redirect_to admin_initiatives_path
    else
      render :action => "new"
    end
  end

  def update
    @initiative.update_attributes(initiative_params)
    redirect_to admin_initiatives_path
  end

  def destroy
    @initiative.destroy
    redirect_to admin_initiatives_path
  end

  def show
    @signatories = @initiative.signings.joins(:organization).order("organizations.cop_state, organizations.name")
  end

  private
    def load_initiative
      @initiative = Initiative.find params[:id] if params[:id]
    end

    def initiative_params
      params.require(:initiative).permit(:name)
    end
end
