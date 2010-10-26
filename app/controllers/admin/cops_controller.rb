class Admin::CopsController < AdminController
  before_filter :load_organization, :except => :introduction
  before_filter :add_cop_form_js
  before_filter :no_unapproved_organizations_access
  before_filter :set_session_template, :only => :new
  before_filter :only_editable_cops_go_to_edit, :only => :edit
  
  def introduction
  end
  
  def new
    unless CommunicationOnProgress::TYPES.include?(session[:cop_template])
      flash[:error] = "Please select the type of COP you would like to submit."
      redirect_to cop_introduction_path
    end
    
    @communication_on_progress = @organization.communication_on_progresses.new(web_based: false)
    @communication_on_progress.init_cop_attributes
    @submitted = false
  end
  
  def create
    @communication_on_progress = @organization.communication_on_progresses.new(params[:communication_on_progress])
    @communication_on_progress.type = session[:cop_template]
    if @communication_on_progress.save
      flash[:notice] = "The COP was #{@communication_on_progress.state}."
      clear_session_template
      redirect_to admin_organization_communication_on_progress_path(@communication_on_progress.organization.id, @communication_on_progress)
    else
      # we want to preselect the submit tab
      @submitted = true
      render :action => "new"
    end
  end

  def update
    @communication_on_progress.update_attributes(params[:communication_on_progress])
    redirect_to admin_organization_communication_on_progress_path(@organization.id, @communication_on_progress)
  end

  def destroy
    @communication_on_progress.destroy
    redirect_to dashboard_path(tab: 'cops')
  end
  
  private
  
    def set_session_template
      session[:cop_template] = params[:type_of_cop]
    end
    
    def clear_session_template
      session[:cop_template] = nil
    end
  
    def load_organization
      @communication_on_progress = CommunicationOnProgress.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
    
    def add_cop_form_js
      (@javascript ||= []) << 'cop_form'
    end
    
    def only_editable_cops_go_to_edit
      unless @communication_on_progress.editable?
        flash[:notice] = "You cannot edit this COP"
        redirect_to dashboard_path(:tab => 'cops')
      end
    end
end
