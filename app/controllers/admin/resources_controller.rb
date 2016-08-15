class Admin::ResourcesController < AdminController
  before_filter :no_organization_or_local_network_access
  before_filter :load_form_resources, only: [:new, :edit, :create, :update]

  def index
    @resources = Resource.with_principles_count
      .order(order_from_params)
  end

  def show
    @resource = ResourcePresenter.new(find_resource(params[:id]))
  end

  def new
    @resource = ResourcePresenter.new(Resource.new)
  end

  def edit
    @resource = ResourcePresenter.new(find_resource(params[:id]))
  end

  def create
    updater = ResourceUpdater.new(resource_params)
    if updater.submit
      redirect_to admin_resources_url, notice: 'Resource created.'
    else
      @resource = ResourcePresenter.new(updater.resource)
      render action: 'new'
    end
  end

  def update
    @resource = find_resource(params[:id])
    updater = ResourceUpdater.new(resource_params, @resource)
    if updater.submit
      redirect_to [:admin, @resource], notice: 'Resource updated.'
    else
      @resource = ResourcePresenter.new(@resource)
      render action: 'edit'
    end
  end

  def destroy
    @resource = find_resource(params[:id])
    @resource.destroy
    redirect_to admin_resources_url, notice: 'Resource destroyed.'
  end

  def approve
    @resource = find_resource(params[:id])
    if allowed_to_approve
      @resource.approved_by_id = current_contact.id
      @resource.approve!
      redirect_to [:admin, @resource], notice: 'Resource approved.'
    else
      redirect_to [:admin, @resource], notice: 'Failed to approve resource.'
    end
  end

  def revoke
    @resource = find_resource(params[:id])
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
      :image,
      :year,
      :content_type,
      principle_ids: [],
      author_ids: [],
      links: [
        :id,
        :title,
        :url,
        :link_type,
        :language_id
      ],
      topic_ids: [],
      issue_ids: [],
      sector_ids: [],
      sustainable_development_goal_ids: []
    )
  end

  def find_resource(id)
    Resource.preload(taggings: [:topic, :issue, :sector]).find(id)
  end

end
