class Admin::CopsController < AdminController
  before_filter :load_organization
  
  def new
    @cop = @organization.communication_on_progresses.new
  end
  
  def create
    @cop = @organization.communication_on_progresses.new(params[:communication_on_progress])
    #@cop.contact_id = current_user.id

    if @cop.save
      flash[:notice] = 'COP was successfully created.'
      redirect_to dashboard_path
    else
      render :action => "new"
    end
  end

  def update
    @cop.update_attributes(params[:communication_on_progress])
    redirect_to [@organization, @cop]
  end

  def destroy
    @cop.destroy
    redirect_to dashboard_path
  end

  private
    def load_organization
      @cop = CommunicationOnProgress.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
