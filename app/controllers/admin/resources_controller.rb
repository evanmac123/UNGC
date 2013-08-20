class Admin::ResourcesController < AdminController

  before_filter :no_organization_or_local_network_access
  before_filter :load_form_resources, only: [:new, :edit, :create, :update]

  def index
    @resources = Resource
      .order(order_from_params)
      .paginate(page:params[:page],
                per_page:Resource.per_page)
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def new
    @resource_form = ResourceForm.new
  end

  def edit
    @resource_form = ResourceForm.new(Resource.find(params[:id]))
  end

  def create
    @resource_form = ResourceForm.new
    if @resource_form.submit(params[:resource])
      redirect_to admin_resources_url, notice: 'Resource created.'
    else
      render action: 'new'
    end
  end

  def update
    @resource_form = ResourceForm.new(Resource.find(params[:id]))
    if @resource_form.submit(params[:resource])
      redirect_to [:admin, @resource_form], notice: 'Resource updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @resource = Resource.find(params[:id])
    @resource.destroy
    redirect_to admin_resources_url, notice: 'Resource destroyed.'
  end

  def approve
    @resource = Resource.find(params[:id])
    if allowed_to_approve
      @resource.approve!
      redirect_to admin_resources_url, notice:'Resource approved'
    else
      redirect_to admin_resources_url, notice:'Failed to approve resource.'
    end
  end

  private

  def allowed_to_approve
    @resource.can_approve? && current_contact.is?(Role.website_editor)
  end

  def order_from_params
    @order = [params[:sort_field] || 'updated_at', params[:sort_direction] || 'DESC'].join(' ')
  end

  def load_form_resources
    @topics = Principle.topics_menu
    @authors = Author.scoped
    @languages = Language.scoped
    @types = ResourceLink::TYPES
  end

end
