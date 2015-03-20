class Admin::RolesController < AdminController
  before_filter :no_organization_or_local_network_access

  def index
    @roles = Role.all
  end

  def new
    @role = Role.new
  end

  def edit
    @role = Role.find(params[:id])
  end

  def create
    @role = Role.new(role_params)
    if @role.save
      flash[:notice] = 'Role was successfully created.'
      redirect_to(admin_roles_path)
    else
      render :action => "new"
    end
  end

  def update
    @role = Role.find(params[:id])
    if @role.update_attributes(role_params)
      flash[:notice] = 'Role was successfully updated.'
      redirect_to(admin_roles_path)
    else
      render :action => "edit"
    end
  end

  def destroy
    @role = Role.find(params[:id])
    @role.destroy
    flash[:notice] = 'Role was deleted.'
    redirect_to(admin_roles_path)
  end

  private

  def role_params
    params.require(:role).permit(
      :name,
      :initiative_id,
      :description,
      :position
    )
  end
end
