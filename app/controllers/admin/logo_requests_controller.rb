class Admin::LogoRequestsController < AdminController
  before_filter :load_organization, :only => [:new, :create, :show, :edit, :update, :destroy, :approve, :reject, :agree, :download]
  before_filter :no_unapproved_organizations_access

  # Define state-specific index methods
  %w{pending_review in_review unreplied approved rejected accepted}.each do |method|
    define_method method do
      # use custom index view if defined
      render case method
        when 'pending_review'
          @logo_requests = LogoRequest.pending_review.all(:order => 'created_at' )
          method
        when 'in_review'
          @logo_requests = LogoRequest.in_review.all
          method
        when 'unreplied'
          @logo_requests = LogoRequest.unreplied.all
          method
        when 'approved'
          @logo_requests = LogoRequest.approved.all(:order => 'status_changed_on')
          method
        when 'rejected'
          @logo_requests = LogoRequest.rejected.all(:order => 'status_changed_on')
          method
        when 'accepted'
          @logo_requests = LogoRequest.accepted.all(:order => 'accepted_on')
          method
        else
          'index'
      end
    end
  end
  
  def index
    @logo_requests = LogoRequest.all
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
      flash[:notice] = 'Logo request was successfully created.'
      redirect_to admin_organization_logo_request_path(@organization.id, @logo_request.id)
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
end
