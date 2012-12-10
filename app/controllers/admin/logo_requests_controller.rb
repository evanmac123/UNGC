class Admin::LogoRequestsController < AdminController
  before_filter :load_organization, :only => [:new, :create, :show, :edit, :update, :destroy, :approve, :reject, :agree, :download]
  before_filter :no_unapproved_organizations_access

  # Define state-specific index methods
  %w{pending_review in_review unreplied approved rejected}.each do |method|
    define_method method do
      # use custom index view if defined
      render case method
        when 'pending_review'
          @logo_requests = LogoRequest.pending_review.includes(:organization)
                              .order(order_from_params('created_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'in_review'
          @logo_requests = LogoRequest.in_review.includes(:organization)
                              .order(order_from_params('updated_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'unreplied'
          @logo_requests = LogoRequest.unreplied.includes(:organization)
                              .order(order_from_params('updated_at', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          @list_name = 'Updated Logo Requests'
          'in_review'
        when 'approved'
          @logo_requests = LogoRequest.approved_or_accepted.includes(:organization)
                              .order(order_from_params('approved_on', 'DESC'))
                              .paginate(:page     => params[:page],
                                        :per_page => LogoRequest.per_page)
          method
        when 'rejected'
          @logo_requests = LogoRequest.rejected.includes(:organization)
                              .order(order_from_params('updated_at', 'DESC'))
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
    if @logo_request.approved? && current_contact.from_organization?
      render :template => 'admin/logo_requests/logo_terms'
    end
  end

  def create
    @logo_request = @organization.logo_requests.new(params[:logo_request])
    @logo_request.logo_comments.first.contact_id = current_contact.id

    if @logo_request.save
      flash.now[:notice] = 'Thank you, your Logo Request was received.'
      render :action => "confirmation"
    else
      render :action => "new"
    end
  end

  def update
    @logo_request.update_attributes(params[:logo_request])
    if params[:commit] == "Save logos"
      flash[:notice] = 'The approved logos have been saved. You may now approve the Logo Request.'
      redirect_to new_admin_logo_request_logo_comment_path(@logo_request)
    else
      redirect_to admin_organization_logo_request_path(@organization.id, @logo_request.id)
    end
  end

  def destroy
    @logo_request.destroy
    redirect_to admin_organization_path(@organization.id)
  end

  def agree
    @logo_request.accept
    flash[:notice] = 'Thank you for accepting the Logo Policy. Your logos will be available for the next 7 days.'
    redirect_to admin_organization_logo_request_path(@organization.id, @logo_request, :tab => :approved)
  end

  def download
    if @logo_request.can_download_files?
      logo_file = @logo_request.logo_files.first(:conditions => ['logo_file_id=?', params[:logo_file_id]])
      send_file logo_file.zip.path, :type => 'application/x-zip-compressed'
    else
      flash[:error] = "Approved logo files must be downloaded within 7 days of accepting the Logo Policy."
      redirect_to admin_organization_logo_request_path(@organization.id, @logo_request, :tab => :approved)
    end
  end

  private
    def load_organization
      @logo_request = LogoRequest.visible_to(current_contact).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end

    def order_from_params(field, direction)
      @order = [params[:sort_field] || field, params[:sort_direction] || direction].join(' ')
    end
end
