class CommentsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :load_commentable
  helper_method :commentable_path
  
  def new
    @comment = @commentable.comments.new
  end
  
  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.state_event = params[:commit].downcase
    @comment.contact_id = current_user.id

    if @comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to commentable_path(@commentable) 
    else
      render :action => "new"
    end
  end
  
  private
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
      commentable.is_a?(Organization) ? commentable : [commentable.organization, commentable]
    end
end
