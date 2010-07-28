class CopsController < ApplicationController
  helper :cops, :pages, 'admin/cops'
  before_filter :determine_navigation
  before_filter :find_cop, :except => [:feed]

  def show 
  end
  
  def feed
    @communication_on_progresses = CommunicationOnProgress.find(:all, :order => "updated_at ASC", :limit => 20)
    #@communication_on_progresses = [CommunicationOnProgress.find(7586)]
    respond_to do |format|
      format.atom 
    end
  end

  private
  def find_cop
    @cop = find_cop_by_id unless params[:id].blank?
    @cop = find_cop_by_cop_and_org unless @cop
    redirect_to root_path unless @cop # FIXME: Should redirect to search?
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
