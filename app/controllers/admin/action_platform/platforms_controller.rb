class Admin::ActionPlatform::PlatformsController < AdminController
  
	# prevents non authorised visitors
	before_filter :no_organization_or_local_network_access
  
	# set instance variable with the appropriate platform
	before_filter :load_platform
	
	
  def index
		# TODO need to eager load relationships count. Currently the view triggers an 2(N+1)
		@platforms = ::ActionPlatform::Platform.all.order("updated_at DESC")
  end

  def new
    @platform = ::ActionPlatform::Platform.new
  end

  def create
    @platform = ::ActionPlatform::Platform.new(platform_params)
    if @platform.save
      flash[:notice] = 'Platform created.'
      redirect_to admin_action_platform_platforms_path
    else
      render :action => "new"
    end
  end

  def update
		@platform.attributes = platform_params
    if @platform.save
			flash[:notice] = 'Platform updated.'
			redirect_to admin_action_platform_platforms_path
		else
			render :action => "edit"
		end
  end

  def destroy
    if @platform.destroy
			flash[:notice] = "Platform removed."
		else
			flash[:notice] = 'Sorry, there was a problem removing the platform.'
		end
    redirect_to admin_action_platform_platforms_path
  end
	
	
  def show
    @subscriptions = fetch_subscriptions(@platform)
  end

  private
    
		def load_platform
      @platform = ::ActionPlatform::Platform.find params[:id] if params[:id]
    end
		
		# TODO this might require some extra TLC. The order is not very intuitive.
		def fetch_subscriptions(platform)
			platform.
			subscriptions.
			order("action_platform_subscriptions.created_at DESC").
			includes(organization: [:organization_type]).
			order("organizations.cop_state, organizations.name")
		end

    def platform_params
      params.require(:action_platform_platform).permit(
        :name,
        :description,
				:slug
      )
    end
end
