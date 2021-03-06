# frozen_string_literal: true

class Admin::OrganizationsController < AdminController
  helper Admin::DueDiligence::Helper

  before_filter :load_organization, :only => [:show, :edit, :update, :destroy, :approve, :reject, :reverse_roles, :show_welcome_letter]
  before_filter :load_organization_types, :only => :new
  before_filter :no_rejected_organizations_access, :only => :edit
  before_filter :no_access_to_other_organizations
  before_filter :fetch_registration, only: [:edit, :update]

  def index
    @organizations = Organization.order(order_from_params)
                        .paginate(:page     => page,
                                  :per_page => Organization.per_page)
  end

  def new
    @organization = Organization.new(:employees => 10)
    @organization.social_network_handles.build
  end

  def show
    @organization = present(@organization)
  end

  def create
    org_updater = OrganizationUpdater.new(organization_params, registration_params)

    if org_updater.create_signatory_organization
      flash[:notice] = 'Organization was successfully created.'
      redirect_to( admin_organization_path(org_updater.organization.id) )
    else
      @organization = org_updater.organization
      render :action => "new"
    end
  end

  def edit
    @organization = present(@organization)
    @organization_types = OrganizationType.staff_types
    @organization.social_network_handles.build unless @organization.social_network_handles.exists?
    @sectors, @disabled_sectors = load_sectors
  end

  def update
    org_updater = OrganizationUpdater.new(organization_params, registration_params)
    if org_updater.update(@organization, current_contact)
      flash[:notice] = 'Organization was successfully updated.'
      redirect_to_dashboard
    else
      @organization_types = OrganizationType.staff_types
      @sectors, @disabled_sectors = load_sectors
      @organization = present(@organization)
      render :action => "edit"
    end
  end

  def destroy
    if @organization.destroy
      flash[:notice] = 'Organization was deleted.'
      redirect_to( admin_organizations_path )
    end
  end

  # switch roles of CEO / Contact Point and transfer login
  def reverse_roles
    if @organization.reverse_roles
      flash[:notice] = 'The CEO and Contact Point roles were reversed.'
    else
      flash[:error] = @organization.errors.full_messages.to_sentence
    end
    redirect_to admin_organization_path(@organization.id)
  end

  def show_welcome_letter
    render file: "admin/organizations/welcome_letter_#{@organization.organization_type_name_for_custom_links}" , :layout => "welcome_letter"
  end

  # Define state-specific index methods
  %w{approved rejected pending_review network_review delay_review in_review updated}.each do |method|
    define_method method do
      # use custom index view if defined
      render case method
        when 'approved'
          @organizations = Organization.send(method).participants.order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        when 'pending_review'
          @organizations = Organization.send(method).includes(:participant_manager)
                              .order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          unless Search.running?
            flash.now[:error] = "Notice: the search index is being updated. Matching organization names are not being listed. Please check again in a few minutes."
          end
          method
        when 'in_review'
          @organizations = Organization.send(method).includes(:comments)
                              .order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        when 'updated'
          @organizations = Organization.unreplied.includes(:comments)
                              .order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        when 'network_review'
          @organizations = Organization.send(method).includes(:participant_manager)
                              .order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        when 'delay_review'
          @organizations = Organization.send(method).includes(:comments)
                              .order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        when 'rejected'
          @organizations = Organization.send(method).order(order_from_params)
                              .paginate(:page     => page,
                                        :per_page => Organization.per_page)
          method
        else
          @organizations = Organization.send(method).order(order_from_params)
                              .paginate(:page     => page,
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
      if organization_id =~ /\A[0-9]+\Z/ # it's all numbers
        @organization = Organization.find(organization_id)
      else
        @organization = Organization.find_by_param(organization_id)
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
                 page: page,
                 indices: ['organization_core']}
      options[:with] ||= {}
      filter_options_for_country(options) if params[:country]
      filter_options_for_business_type(options) if params[:business_type]
      filter_options_for_joined_on(options) if params[:joined_after].present? && params[:joined_before].present?

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword => keyword)
      options.delete(:with) if options[:with] == {}
      #logger.info " ** Organizations search with options: #{options.inspect}"
      @results = Organization.search (Riddle::Query.escape(keyword) || nil), options

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
        options[:with].merge!(cop_state: Zlib.crc32(cop_status)) unless skip_cop_status
      elsif business_type_selected == OrganizationType::NON_BUSINESS
        options[:with].merge!(organization_type_id: params[:organization_type_id].to_i) unless params[:organization_type_id].blank?
      end
    end

    def filter_options_for_joined_on(options)
      if params[:joined_after]
        options[:with].merge!(joined_on: date_from_params(:joined_after)..date_from_params(:joined_before))
      end
    end

    def date_from_params(param_name)
      Time.zone.parse params[param_name]
    end

    def fetch_registration
      @organization.registration
    end

    def redirect_to_dashboard
      if current_contact.from_ungc?
        redirect_to( admin_organization_path(@organization.id) )
      elsif current_contact.from_organization?
        redirect_to( dashboard_path )
      end
    end

    def page
      params[:page]
    end

    def organization_id
      params[:id]
    end

    def organization_params
      params.fetch(:organization, {}).permit!
    end

    def registration_params
      params.fetch(:non_business_organization_registration, {}).permit(
        :date,
        :place,
        :authority,
        :number,
        :mission_statement
      )
    end

    def load_sectors
      sectors = SectorTree.new
      disabled = if current_contact.from_ungc?
        []
      else
        sectors.preserved.map(&:id)
      end
      [sectors, disabled]
    end

    def present(organization)
      OrganizationPresenter.new(organization, current_contact)
    end

end
