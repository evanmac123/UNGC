class Admin::OrganizationsController < AdminController
  before_filter :load_organization, :only => [:show, :edit, :update, :destroy, :approve, :reject, :reverse_roles]
  before_filter :load_organization_types, :only => :new
  before_filter :no_rejected_organizations_access, :only => :edit
  before_filter :no_access_to_other_organizations
  helper :participants
  
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
    @organization_types = OrganizationType.staff_types
  end

  def update
    @organization.state = Organization::STATE_IN_REVIEW if @organization.state == Organization::STATE_PENDING_REVIEW
    # when an application is in review, we record who made the last change
    @organization.set_replied_to(current_user) if Organization::STATE_IN_REVIEW
    @organization.set_manual_delisted_status if params[:organization][:active] == '0'
    @organization.last_modified_by_id = current_user.id
    
    if @organization.update_attributes(params[:organization])
      flash[:notice] = 'Organization was successfully updated.'
      if current_user.from_ungc?
        redirect_to( admin_organization_path(@organization.id) )
      elsif current_user.from_organization?
        redirect_to( dashboard_path )
      end
    else
      @organization_types = OrganizationType.staff_types
      render :action => "edit"
    end
  end

  def destroy
    @organization.destroy
    redirect_to( admin_organizations_path )
  end

  # switch roles of CEO / Contact Point and transfer login
  def reverse_roles
    if @organization.reverse_roles
      flash[:notice] = 'The CEO and Contact Point roles were reversed.'
    else 
      flash[:error] = @organization.errors.full_messages.to_sentence
    end
    redirect_to( admin_organization_path(@organization.id, {:tab => 'contacts'}) )
  end

  # Define state-specific index methods
  %w{approved rejected pending_review network_review in_review updated}.each do |method|
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
        when 'in_review'
          @organizations = Organization.send(method).all(:include => [:comments], :order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        when 'updated'
          @organizations = Organization.unreplied.all(:include => [:comments], :order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        when 'network_review'
          @organizations = Organization.send(method).all(:order => order_from_params)
                              .paginate(:page     => params[:page],
                                        :per_page => Organization.per_page)
          method
        when 'rejected'
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
  
  def search
    if params[:commit] == 'Search'
      # intercept search by ID and check for number
      if params[:keyword] =~ /\A[+\-]?\d+\Z/
        org_id = params[:keyword].to_i
        if Organization.find_by_id(org_id)
          redirect_to(admin_organization_path(org_id))
        else
          flash.now[:error] = "There is no organization with the ID #{org_id}." 
          render :action => "search"
        end
      else
        display_search_results
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
      @organization_types = OrganizationType.staff_types
    end
    
    def order_from_params
      if params[:sort_field] == 'comment'
        @order = ['comments.contact_id', params[:sort_direction] || 'DESC'].join(' ')
      else
        @order = [params[:sort_field] || 'updated_at', params[:sort_direction] || 'DESC'].join(' ')
      end
    end

    def display_search_results
      keyword = params[:keyword].force_encoding("UTF-8")
      options = {per_page: (params[:per_page] || 15).to_i,
                 page: params[:page],
                 star: true}
      options[:with] ||= {}
      filter_options_for_country(options) if params[:country]
      filter_options_for_business_type(options) if params[:business_type]
      # filter_options_for_joined_on(options)

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword      => keyword)
                                    # .merge(:joined_after => date_from_params(:joined_after))
      options.delete(:with) if options[:with] == {}
      #logger.info " ** Organizations search with options: #{options.inspect}"
      @results = Organization.search keyword || '', options
      
      if @results.total_entries > 0
        render :action => 'search_results'
      else
        flash.now[:error] = "Sorry, there are no organizations with '#{keyword}' in their name."
        render :action => "search"
      end
      
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
    
    def filter_options_for_joined_on(options)
      if params[:joined_after]
        options[:with].merge!(joined_on: date_from_params(:joined_after)..Time.now)
      end
    end
    
    def date_from_params(param_name)
      Time.parse [params[param_name][:year],
                    params[param_name][:month],
                    params[param_name][:day]].join('-')
    end
end
