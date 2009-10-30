class Admin::CopsController < AdminController
  before_filter :load_organization, :add_cop_form_js
  
  def new
    @communication_on_progress = @organization.communication_on_progresses.new
    # TODO move the line below to the model
    CopAttribute.all.each {|cop_attribute|
      @communication_on_progress.cop_answers.build(:cop_attribute_id => cop_attribute.id,
                                                   :value => false)
    }
  end
  
  def create
    @communication_on_progress = @organization.communication_on_progresses.new(params[:communication_on_progress])
    #@cop.contact_id = current_user.id

    if @communication_on_progress.save
      flash[:notice] = 'COP was successfully created.'
      redirect_to dashboard_path
    else
      render :action => "new"
    end
  end

  def update
    @communication_on_progress.update_attributes(params[:communication_on_progress])
    redirect_to [@organization, @communication_on_progress]
  end

  def destroy
    @communication_on_progress.destroy
    redirect_to dashboard_path
  end

  private
    def load_organization
      @communication_on_progress = CommunicationOnProgress.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
    
    def add_cop_form_js
      (@javascript ||= []) << 'cop_form'
    end    
end
