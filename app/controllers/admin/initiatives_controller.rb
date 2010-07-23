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
    @initiative = Initiative.new(params[:initiative])

    if @initiative.save
      flash[:notice] = 'Initiative created.'
      redirect_to admin_initiatives_path
    else
      render :action => "new"
    end
  end

  def update
    @initiative.update_attributes(params[:initiative])
    redirect_to admin_initiatives_path
  end

  def destroy
    @initiative.destroy
    redirect_to admin_initiatives_path
  end
  
  def show
    # @signatories = @initiative.signings.all(:joins => 'JOIN organizations o ON o.id = signings.organization_id', :order => "o.cop_state, o.name")
    @signatories = @initiative.signings.all(:joins => :organization, :order => "organizations.cop_state, organizations.name")

  end

  private
    def load_initiative
      @initiative = Initiative.find params[:id] if params[:id]
    end
end
