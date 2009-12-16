class Admin::LogoRequestsController < AdminController
  before_filter :load_organization

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
    flash[:notice] = 'You accepted the terms and conditions, and can download the logo for the next 7 days'
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
