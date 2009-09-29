class CommentsController < ApplicationController
  layout 'admin'
  before_filter :login_required, :load_commentable
  
  def new
    @comment = @commentable.comments.new
  end
  
  def create
    @comment = @commentable.comments.new(params[:comment])
    @comment.state_event = params[:commit].downcase
    @comment.contact_id = current_user.id

    if @comment.save
      flash[:notice] = 'Comment was successfully created.'
      redirect_to [@commentable.organization, @commentable]
    else
      render :action => "new"
    end
  end
  
  private
    def load_commentable
      if params[:case_story_id]
        commentable_class = CaseStory 
        commentable_id = params[:case_story_id]
      end
      @commentable = commentable_class.find commentable_id
      @organization = @commentable.organization
    end
end
