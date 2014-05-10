class CopsController < ApplicationController
  helper :cops, :pages, 'admin/cops'
  before_filter :determine_navigation
  before_filter :find_cop, :except => [:feed]

  def show
    @communication = CommunicationPresenter.create(@communication_on_progress, current_contact)
  end

  def feed
    @cops_for_feed = CommunicationOnProgress.approved.for_feed

    respond_to do |format|
      format.atom { render :layout => false }
    end
  end

  private

    def find_cop
      @communication_on_progress = find_cop_by_id unless params[:id].blank?
      @communication_on_progress = find_cop_by_cop_and_org unless @communication_on_progress
      redirect_to DEFAULTS[:cop_path] unless @communication_on_progress # FIXME: Should redirect to search?
    end

    def find_cop_by_id
      CommunicationOnProgress.find_by_id(params[:id])
    end

    def find_cop_by_cop_and_org
      @organization = Organization.find_by_param(params[:organization])
      @organization.communication_on_progresses.find_by_param(params[:cop]) if @organization
    end

end
