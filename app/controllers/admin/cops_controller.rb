class Admin::CopsController < AdminController
  before_filter :load_organization, :add_cop_form_js
  before_filter :no_unapproved_organizations_access
  before_filter :only_editable_cops_go_to_edit, :only => :edit
  
  def new
    @communication_on_progress = @organization.communication_on_progresses.new(web_based: false)
    @communication_on_progress.init_cop_attributes

    partials = %w{first_time basic intermediate advanced}
    @cop_partial = params[:type_of_cop]
    unless partials.include?(params[:type_of_cop])
      flash[:error] = "Please select the type of COP you would like to submit."
      redirect_to cop_introduction_path
    end
    
  end
  
  def create
    @communication_on_progress = @organization.communication_on_progresses.new(params[:communication_on_progress])
      # # TODO: these defaults and setting should be moved to the COP model
      # case params[:type_of_cop]
      #   when 'basic'
      #     @communication_on_progress.format = 'basic'
      #     @communication_on_progress.include_continued_support_statement = true
      #     @communication_on_progress.include_measurement = true
      #   when 'intermediate'
      #     @communication_on_progress.additional_questions = false
      #   when 'advanced'
      #     @communication_on_progress.additional_questions = true
      # end
    if @communication_on_progress.save
      flash[:notice] = "The COP was #{@communication_on_progress.state}."
      redirect_to admin_organization_communication_on_progress_path(@communication_on_progress.organization.id, @communication_on_progress)
    else
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
