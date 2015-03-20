class Admin::SectorsController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    @sectors = Sector.all
  end

  def new
    @sector = Sector.new
  end

  def edit
    @sector = Sector.find(params[:id])
  end

  def create
    @sector = Sector.new(sector_params)
    if @sector.save
      flash[:notice] = 'Sector was successfully created.'
      redirect_to(admin_sectors_path)
    else
      render :action => "new"
    end
  end

  def update
    @sector = Sector.find(params[:id])
    if @sector.update_attributes(sector_params)
      flash[:notice] = 'Sector was successfully updated.'
      redirect_to(admin_sectors_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @sector = Sector.find(params[:id])
    @sector.destroy
    redirect_to(admin_sectors_path)
  end

  private

  def sector_params
    params.require(:sector).permit(
      :name,
      :icb_number,
      :parent_id
    )
  end
end
