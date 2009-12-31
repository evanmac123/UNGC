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
    @sector = Sector.new(params[:sector])
    if @sector.save
      flash[:notice] = 'Sector was successfully created.'
      redirect_to(admin_sectors_path)
    else
      render :action => "new"
    end
  end

  def update
    @sector = Sector.find(params[:id])
    if @sector.update_attributes(params[:sector])
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
end
