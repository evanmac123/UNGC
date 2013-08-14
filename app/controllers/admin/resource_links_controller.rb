class Admin::ResourceLinksController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_resource
  before_filter :load_link, only:[:edit, :update, :destroy]
  before_filter :load_select_menu_resources, only:[:new, :edit, :create, :update]

  def new
    @link = @resource.links.build
  end

  def edit
  end

  def create
    @link = @resource.links.build(params[:resource_link])
    if @link.save
      redirect_to edit_admin_resource_url(@resource), notice: 'Link created'
    else
      render action:'new'
    end
  end

  def update
    if @link.update_attributes(params[:resource_link])
      redirect_to edit_admin_resource_url(@resource), notice: 'Link updated'
    else
      render action:'edit'
    end
  end

  def destroy
    @link.destroy
    redirect_to edit_admin_resource_url(@resource), notice: 'Link deleted.'
  end

  private

  def load_resource
    @resource = Resource.includes(:links).find(params[:resource_id])
  end

  def load_link
    @link = @resource.links.find(params[:id])
  end

  def load_select_menu_resources
    @link_types = ResourceLink::TYPES.map {|k,v| [v,k]}
    @languages = Language.scoped.map {|l| [l.name, l.id]}
  end

end
