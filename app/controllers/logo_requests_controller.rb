class LogoRequestsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :load_organization

  def new
    @logo_request = @organization.logo_requests.new
    @logo_request.logo_comments << @logo_request.logo_comments.new
  end
  
  def show
    if @logo_request.approved? && current_user.from_organization?
      render :template => 'logo_requests/logo_terms.html.haml'
    end
  end

  def create
    @logo_request = @organization.logo_requests.new(params[:logo_request])
    @logo_request.logo_comments.first.contact_id = current_user.id

    if @logo_request.save
      flash[:notice] = 'Logo request was successfully created.'
      redirect_to @organization
    else
      render :action => "new"
    end
  end

  def update
    @logo_request.update_attributes(params[:logo_request])
    redirect_to [@organization, @logo_request]
  end

  def destroy
    @logo_request.destroy
    redirect_to @organization
  end

  def agree
    @logo_request.accept
    @logo_request.update_attribute(:accepted_on, Time.now)
    flash[:notice] = 'You accepted the terms and conditions, and can download the logo for the next 7 days'
    redirect_to [@organization, @logo_request]
  end
  
  def download
    if @logo_request.can_download_files?
      logo_file = @logo_request.logo_files.first(:conditions => ['logo_file_id=?', params[:logo_file_id]])
      # TODO allow upload of zip file
      send_file :file => logo_file.zip.path, :type => 'application/x-zip-compressed'
    else
      flash[:error] = "You only had 7 days to download the file."
      redirect_to [@organization, @logo_request]
    end
  end
  
  private
    def load_organization
      @logo_request = LogoRequest.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
