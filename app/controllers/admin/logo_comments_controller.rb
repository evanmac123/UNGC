class Admin::LogoCommentsController < AdminController
  before_filter :load_logo_request
  
  def new
    @logo_comment = @logo_request.logo_comments.new
  end
  
  def create
    @logo_comment = @logo_request.logo_comments.new(params[:logo_comment])
    @logo_comment.state_event = params[:commit].downcase
    @logo_comment.contact_id = current_user.id

    if @logo_comment.save
      flash[:notice] = 'Logo comment was successfully created.'
      redirect_to admin_organization_logo_request_path(@logo_request.organization_id, @logo_request)
    else
      render :action => "new"
    end
  end
  
  private
    def load_logo_request
      @logo_request = LogoRequest.find params[:logo_request_id]
    end
end
