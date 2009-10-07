class CopsController < ApplicationController
  before_filter :determine_navigation
  before_filter :find_cop

  def show
  end

  private
  def find_cop
    @cop = find_cop_by_id unless params[:id].blank?
    @cop = find_cop_by_cop_and_org unless @cop
    redirect_to root_path unless @cop # FIXME: Should redirect to search?
  end

  def determine_navigation
    @look_for_path = case params[:navigation]
    when 'notable'
      '/COP/notable_cops.html'
    else
      '/COP/cop_search.html'
    end
  end
  
  private
  def find_cop_by_id
    CommunicationOnProgress.find_by_id(params[:id])
  end
  
  def find_cop_by_cop_and_org
    @organization = Organization.find_by_param(params[:organization])
    @organization.communication_on_progresses.find_by_param(params[:cop])
  end
end
