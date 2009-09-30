class ParticipantsController < ApplicationController
  before_filter :determine_navigation
  before_filter :find_participant
  
  def show
  end

  private
  def find_participant
    if params[:id] =~ /\A[0-9]+\Z/ # it's all numbers
      @participant = Organization.find_by_id(params[:id])
    else
      @participant = Organization.find_by_param(params[:id])
    end
    redirect_to root_path unless @participant # FIXME: Should redirect to search?
  end
  
  def determine_navigation
    logger.info " ** #{params[:navigation]}"
    @look_for_path = case params[:navigation]
    when 'inactive'
      '/COP/inactives.html'
    when 'noncommunicating'
      '/COP/non_communicating.html'
    when 'notable'
      '/COP/notable_cops.html'
    else
      '/COP/cop_search.html'
    end
  end
end
