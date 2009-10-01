class CaseStoriesController < ApplicationController
  layout 'admin'
  before_filter :login_required, :load_organization
  
  def new
    @case_story = @organization.case_stories.new
  end
  
  def create
    @case_story = @organization.case_stories.new(params[:case_story])
    @case_story.contact_id = current_user.id

    if @case_story.save
      flash[:notice] = 'Case Story was successfully created.'
      redirect_to @organization
    else
      render :action => "new"
    end
  end

  def update
    @case_story.update_attributes(params[:case_story])
    redirect_to [@organization, @case_story]
  end

  def destroy
    @case_story.destroy
    redirect_to @organization
  end

  private
    def load_organization
      @case_story = CaseStory.visible_to(current_user).find(params[:id]) if params[:id]
      @organization = Organization.find params[:organization_id]
    end
end
