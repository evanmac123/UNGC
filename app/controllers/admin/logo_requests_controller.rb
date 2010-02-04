class Admin::LogoRequestsController < AdminController
  before_filter :load_organization, :only => [:new, :create, :show, :edit, :update, :destroy, :approve, :reject, :agree, :download]
  before_filter :no_unapproved_organizations_access

  # Define state-specific index methods
  %w{pending_review in_review unreplied approved rejected accepted}.each do |method|
    define_method method do
      # use custom index view if defined
      render case method
        when 'pending_review'
          @logo_requests = LogoRequest.pending_review.all(:include => :organization,
                                                          :order   => order_from_params('created_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'in_review'
          @logo_requests = LogoRequest.in_review.all(:include => :organization,
                                                     :order   => order_from_params('created_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'unreplied'
          @logo_requests = LogoRequest.unreplied.all(:include => :organization,
                                                     :order   => order_from_params('updated_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'approved'
          @logo_requests = LogoRequest.approved.all(:include => :organization,
                                                    :order   => order_from_params('status_changed_on', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'rejected'
          @logo_requests = LogoRequest.rejected.all(:include => :organization,
                                                    :order   => order_from_params('status_changed_on', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'accepted'
          @logo_requests = LogoRequest.accepted.all(:include => :organization,
                                                    :order   => order_from_params('accepted_on', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        else
          'index'
      end
    end
  end
  
  def index
    @logo_requests = LogoRequest.paginate(:page => params[:page])
  end  
  
  def new
    @logo_request = @organization.logo_requests.new
    @logo_request.logo_comments << @logo_request.logo_comments.new
  end
  
  def show
    if @logo_request.approved? && current_user.from_organization?
      render :template => 'admin/logo_requests/logo_terms.html.haml'
    end
  end

  def create
    @logo_request = @organization.logo_requests.new(params[:logo_request])
    @logo_request.logo_comments.first.contact_id = current_user.id

    if @logo_request.save
      flash[:notice] = 'Your Logo Request was received.'
      render :action => "confirmation" 
    else
      render :action => "new"
    end
  end

  def update
    @logo_request.update_attributes(params[:logo_request])
    redirect_to admin_organization_logo_request_path(@organization.id, @logo_request.id)
  end

  def destroy
    @logo_request.destroy
    redirect_to admin_organization_path(@organization.id)
  end

  def agree
    @logo_request.accept
    flash[:notice] = 'Thank you for accepting the Logo Policy. Your logos will be available for the next 7 days.'
    redirect_to admin_organization_logo_request_path(@organization.id, @logo_request)
  end
  
  def download
    if @logo_request.can_download_files?
      logo_file = @logo_request.logo_files.first(:conditions => ['logo_file_id=?', params[:logo_file_id]])
      send_file logo_file.zip.path, :type => 'application/x-zip-compressed'
    else
      flash[:error] = "You only had 7 days to download the file."
      redirect_to admin_organization_logo_request_path(@organization.id, @logo_request)
    end
  end
  
  private
    def load_organization
      @logo_request = LogoRequest.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
    
    def order_from_params(field, direction)
      @order = [params[:sort_field] || field, params[:sort_direction] || direction].join(' ')
    end
end
