class Admin::ResourcesController < AdminController

  before_filter :no_organization_or_local_network_access
  before_filter :load_resource, except: [:index, :create]

  def index
    @resources = Resource
      .order(order_from_params)
      .paginate(page:params[:page],
                per_page:Resource.per_page)
  end

  def new
    @topics = Topic.roots
    @authors = Author.scoped
  end

  def edit
    @topics = Topic.roots
    @authors = Author.scoped
  end

  def create
    @resource = Resource.new(params[:resource])
    if @resource.save
      redirect_to admin_resources_url, notice: 'Resource created.'
    else
      render action: 'new'
    end
  end

  def update
    if @resource.update_attributes(params[:resource])
      redirect_to [:admin, @resource], notice: 'Resource updated.'
    else
      render action: 'edit'
    end
  end

  def destroy
    @resource.destroy
    redirect_to admin_resources_url, notice: 'Resource destroyed.'
  end

  def approve
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

  def load_resource
    if params.has_key?(:id)
      @resource = Resource.find(params[:id])
    else
      @resource = Resource.new
    end
  end

end
