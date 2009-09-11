class LogoRequestsController < ApplicationController
  layout 'admin'
  before_filter :load_organization

  def new
    @logo_request = @organization.logo_requests.new
  end

  def create
    @logo_request = @organization.logo_requests.new(params[:logo_request])

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
  
  private
    def load_organization
      @logo_request = LogoRequest.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
