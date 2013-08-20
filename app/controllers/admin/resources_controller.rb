class Admin::ResourcesController < AdminController

  before_filter :no_organization_or_local_network_access
  before_filter :load_resource, except: [:index, :create]
  before_filter :load_form_resources, only: [:new, :edit, :create, :update]

  def index
    @resources = Resource
      .order(order_from_params)
      .paginate(page:params[:page],
                per_page:Resource.per_page)
  end

  def show
  end

  def new
  end

  def edit
  end

  def create
    @resource = Resource.new(params[:resource])
    if @resource.save

      params[:resource_links] && params[:resource_links].each do |link|
        @resource.links.create(link.slice(:title, :url, :link_type, :language_id))
      end

      redirect_to admin_resources_url, notice: 'Resource created.'
    else
      render action: 'new'
    end
  end

  def update
    if @resource.update_attributes(params[:resource])

      if params[:resource_links]
        ids = params[:resource_links].map { |l| l[:id].to_i }
        @resource.links.where('id NOT IN (?)',ids).destroy_all

        params[:resource_links].each do |link|
          l = @resource.links.find_or_initialize_by_id(link[:id])
          l.update_attributes(link.slice(:title, :url, :link_type, :language_id))
        end
      end

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

  def load_form_resources
    @topics = Principle.topics_menu
    @authors = Author.scoped
    @languages = Language.scoped
    @types = ResourceLink::TYPES
  end

end
