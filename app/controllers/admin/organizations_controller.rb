class Admin::OrganizationsController < AdminController
  before_filter :load_organization, :only => [:show, :edit, :update, :destroy, :approve, :reject]
  before_filter :load_organization_types, :only => :new
  helper :participants
  
  def index
    @organizations = Organization.paginate :page => params[:page]
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
          @organizations = Organization.send(method).participants.paginate :page => params[:page]
          method
        when 'pending_review'
          @organizations = Organization.send(method).paginate :page => params[:page]
          method
        when 'network_review'
          @organizations = Organization.send(method).paginate :page => params[:page]
          method
        else
          @organizations = Organization.send(method).paginate :page => params[:page]
          'index'
      end
    end
  end
  
  def search
    if params[:commit] == 'Search'
      display_search_results
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
    
    def display_search_results
      options = {per_page: (params[:per_page] || 15).to_i, page: params[:page]}
      options[:with] ||= {}
      filter_options_for_country(options) if params[:country]
      filter_options_for_business_type(options) if params[:business_type]

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword => params[:keyword])
      options.delete(:with) if options[:with] == {}
      logger.info " ** Organizations search with options: #{options.inspect}"
      @results = Organization.search params[:keyword] || '', options
      raise Riddle::ConnectionError unless @results && @results.total_entries
      render :action => 'search_results'
    end
    
    def filter_options_for_country(options)
      options[:with].merge!(country_id: params[:country].map { |i| i.to_i }) 
    end
    
    def filter_options_for_business_type(options)
      business_type_selected = if params[:business_type] != 'all'
        params[:business_type].to_i
      else
        :all # all if it's nil or 'all'
      end

      # we don't need to set this if it's all
      unless business_type_selected == :all
        options[:with].merge!(business: business_type_selected) 
      end

      if business_type_selected == OrganizationType::BUSINESS
        cop_status = params[:cop_status]
        skip_cop_status = cop_status.blank? || cop_status == 'all'
        options[:with].merge!(cop_state: cop_status.to_crc32) unless skip_cop_status
      elsif business_type_selected == OrganizationType::NON_BUSINESS
        options[:with].merge!(organization_type_id: params[:organization_type_id].to_i) unless params[:organization_type_id].blank?
      end
    end
end