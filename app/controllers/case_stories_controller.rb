class CaseStoriesController < ApplicationController
  before_filter :find_case_story, :only => [:show]
  before_filter :determine_navigation
  
  private
    def find_case_story
      @case_story = CaseStory.approved.find_by_identifier params[:id]
      redirect_back_or_to and return false unless @case_story
    end
    
    def default_navigation
      DEFAULTS[:case_story_path]
    end
end
