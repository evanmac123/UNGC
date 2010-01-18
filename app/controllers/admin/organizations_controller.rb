class Admin::OrganizationsController < AdminController
  before_filter :load_organization, :only => [:show, :edit, :update, :destroy, :approve, :reject]
  before_filter :load_organization_types, :only => :new
  
  def index
    @organizations = Organization.all(:order => order_from_params)
                        .paginate(:page     => params[:page],
                                  :per_page => Organization.per_page)
  end

  def new
    @organization = Organization.new
    @organization.organization_type_id = @organization_types.first.id
    @organization.contacts << @organization.contacts.new
  end

  def create
    @organization = Organization.new(params[:organization])

    if @organization.save
      flash[:notice] = 'Organization was successfully created.'
      redirect_to( admin_organization_path(@organization.id) )
    else
      @organization_types = OrganizationType.all(:conditions => ["type_property=?",@organization.organization_type.type_property])
      render :action => "new"
    end
  end
  
  def edit
    @organization_types = OrganizationType.all(:conditions => ["type_property=?",@organization.organization_type.type_property])
  end

  def update
    @organization.state = Organization::STATE_IN_REVIEW if @organization.state == Organization::STATE_PENDING_REVIEW
    @organization.last_modified_by_id = current_user.id
    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to( admin_organization_path(@organization.id) )
    else
      @organization_types = OrganizationType.all(:conditions => ["type_property=?",@organization.organization_type.type_property])
      render :action => "edit"
    end
  end

  def destroy
    @organization.destroy
    redirect_to( admin_organizations_path )
  end

  # Define state-specific index methods
  %w{approved rejected pending_review network_review in_review}.each do |method|
    define_method method do
      # use custom index view if defined
      render case method
        when 'approved'
          @organizations = Organization.send(method).participants.all(:order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        when 'pending_review'
          @organizations = Organization.send(method).all(:order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        when 'network_review'
          @organizations = Organization.send(method).all(:order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        else
          @organizations = Organization.send(method).all(:order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          'index'
      end
    end
  end

  private
    def load_organization
      if params[:id] =~ /\A[0-9]+\Z/ # it's all numbers
        @organization = Organization.find_by_id(params[:id])
      else
        @organization = Organization.find_by_param(params[:id])
      end
    end
    
    def load_organization_types
      method = ['business', 'non_business'].include?(params[:org_type]) ? params[:org_type] : 'business'
      @organization_types = OrganizationType.send method
    end
    
    def order_from_params
      @order = [params[:sort_field] || 'updated_at', params[:sort_direction] || 'DESC'].join(' ')
      logger.info "**** #{@order}"
      @order
    end
end