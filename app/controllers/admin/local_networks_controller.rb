class Admin::LocalNetworksController < AdminController
  before_filter :load_local_network, :only => [:show, :edit, :update, :destroy, :knowledge_sharing]
  before_filter :no_access_to_other_local_networks, :except => [:index, :show, :knowledge_sharing, :update]

  helper Admin::LocalNetworkSubmodelHelper

  def index
    @local_networks = LocalNetwork.unscoped.order(order_from_params).includes(:countries)
    @local_network_guest = Organization.find_by_name(DEFAULTS[:local_network_guest_name])
    @networks_by_region = Country.unscoped
                                  .joins('left join local_networks on countries.local_network_id = local_networks.id')
                                  .order(order_from_params)
                                  .group('local_networks.name, countries.region')
                                  .includes(:local_network)
                                  .reject{|country| country.local_network_id.nil?}
                                  .group_by(&:region)
  end

  def new
    @local_network = LocalNetwork.new(:state => LocalNetwork::STATES[:emerging])
  end

  def show; end

  def edit
    @section ||= params[:section]
    @form_partial = @section ? 'edit_' + @section : 'default_form'
  end

  def create
    @local_network = LocalNetwork.new(local_network_params)
    if @local_network.save
      flash[:notice] = 'Local Network was successfully created.'
      redirect_to(admin_local_networks_path)
    else
      render :action => "new"
    end
  end

  def update
    @section ||= params[:section]
    @form_partial = @section ? 'edit_' + @section : 'default_form'
    if LocalNetworkUpdate.update(@local_network, local_network_params)
      flash[:notice] = 'Local Network was successfully updated.'
      redirect_to admin_local_network_path(@local_network.id, :tab => @section)
    else
      render :action => "edit"
    end
  end

  def knowledge_sharing; end

  def destroy
    @local_network.destroy
    flash[:notice] = 'Local Network was deleted.'
    redirect_to(admin_local_networks_path)
  end

  def edit_resources
    # scopes in Page model
    @sections =  [ 'engagement_framework',
                   'local_network_training_guidance_material',
                   'local_network_issue_specific_guidance',
                   'local_network_news_updates',
                   'local_network_reports' ]
    @pages = {}
    # latest version for each page returned in the scope
    @sections.each { |section| @pages[section] = Page.send(section).map { |page| page.latest_version } }
  end

  private

  def order_from_params
    direction = params.fetch(:sort_direction, 'ASC')
    field     = params.fetch(:sort_field, 'name')
    @order = "local_networks.#{field} #{direction}"
  end

  def load_local_network
    @local_network = LocalNetwork.find(params[:id])
  end

  def network_management_tab?
    !knowledge_sharing_tab?
  end

  def knowledge_sharing_tab?
    action_name == 'knowledge_sharing'
  end

  def local_network_params
    params.fetch(:local_network, {}).permit!
  end

end
