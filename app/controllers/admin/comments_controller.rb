class Admin::CommentsController < AdminController
  before_filter :load_commentable
  before_filter :no_rejected_organizations_access, :only => :new
  helper_method :commentable_path
  
  def new
    @comment = @commentable.comments.new
  end
  
  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.state_event = params[:commit].downcase
    @comment.contact_id = current_user.id

    if @comment.save
      flash[:notice] = set_flash_notice_text(@commentable, @comment)
      redirect_to commentable_path(@commentable) 
    else
      render :action => "new"
    end
  end
  
  private
  
    def set_flash_notice_text(commentable, comment)
      case comment.state_event
        when Organization::EVENT_REVISE
          flash = 'Comment was successfully created.'
          flash += ' The Local Network has been notified by email.' if comment.copy_local_network?
          return flash
        when Organization::EVENT_NETWORK_REVIEW
          'The application is now under review by the Local Network.'          
        when Organization::EVENT_REJECT
          'The application was rejected.'
        when Organization::EVENT_REJECT_MICRO
          flash = 'The Micro Enterprise application was rejected.'
          flash += ' The Local Network has been notified by email.' if commentable.network_report_recipients.count > 0
          return flash
        when Organization::EVENT_APPROVE
          'The application was approved.'
        else
          'Comment was successfully created.'
      end
    end
  
    def load_commentable
      if params[:case_story_id]
        @commentable = CaseStory.find params[:case_story_id]
      elsif params[:communication_on_progress_id]
        @commentable = CommunicationOnProgress.find params[:communication_on_progress_id]
      elsif params[:organization_id]
        @commentable = Organization.find params[:organization_id]
      end
    end
    
    def commentable_path(commentable)
      case commentable
      when CaseStory
        admin_organization_case_story_path(commentable.organization.id, commentable)
      when CommunicationOnProgress
        admin_organization_communication_on_progress_path(commentable.organization.id, commentable)
      when Organization
        admin_organization_path(commentable.id)
      else
        raise "Polymorphic comment wasn't aware of #{commentable.inspect}".inspect
      end
    end
end
