class Admin::ResourcesController < AdminController

  before_filter :no_organization_or_local_network_access
  before_filter :load_form_resources, only: [:new, :edit, :create, :update]

  def index
    @resources = Resource.with_principles_count
      .paginate(page:params[:page],
                per_page:Resource.per_page)
      .order(order_from_params)
  end

  def show
    @resource = Resource.find(params[:id])
  end

  def new
    @resource = Resource.new
  end

  def edit
    @resource = Resource.find(params[:id])
  end

  def create
    updater = ResourceUpdater.new(resource_params)
    if updater.submit
      redirect_to admin_resources_url, notice: 'Resource created.'
    else
      @resource = updater.resource
      render action: 'new'
    end
  end

  def update
    @resource = Resource.find(params[:id])
    updater = ResourceUpdater.new(resource_params, @resource)
    if updater.submit
      redirect_to [:admin, @resource], notice: 'Resource updated.'
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
      @resource.approved_by_id = current_contact.id
      @resource.approve!
      redirect_to [:admin, @resource], notice: 'Resource approved.'
    else
      redirect_to [:admin, @resource], notice: 'Failed to approve resource.'
    end
  end

  def revoke
    @resource = Resource.find(params[:id])
    if allowed_to_revoke
      @resource.revoke!
      redirect_to [:admin, @resource], notice: 'Resource revoked'
    else
      redirect_to [:admin, @resource], notice: 'Failed to revoke resource.'
    end
  end

  private

  def allowed_to_approve
    @resource.can_approve? && current_contact.is?(Role.website_editor)
  end

  def allowed_to_revoke
    @resource.can_revoke? && current_contact.is?(Role.website_editor)
  end

  def order_from_params
    @order = [params[:sort_field] || 'updated_at', params[:sort_direction] || 'DESC'].join(' ')
  end

  def load_form_resources
    @topics = Principle.topics_menu
    @authors = Author.all
    @languages = Language.all
    @types = ResourceLink::TYPES
  end

  def resource_params
    params.fetch(:resource, {}).permit(
      :title,
      :description,
      :isbn,
      :principle_ids,
      :author_ids,
      :image,
      :year,
      :links => [:id, :title, :url, :link_type, :language_id]
    )
  end

end
