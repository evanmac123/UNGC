class OrganizationsController < ApplicationController
  def index
    initiative  = params[:initiative] || :climate
    page        = params[:page] || 1
    per_page    = params[:per_page] || Organization.per_page
    only        = params[:extras] ? params[:extras].split(',') : []
    methods     = params[:methods] ? params[:methods].split(',') : []
    
    @organizations_for_init = Organization.for_initiative(initiative.to_sym)
    @count          = @organizations_for_init.count
    @organizations  = @organizations_for_init.paginate(:page => page.to_s, :per_page => per_page)

    response.headers['Current-Page']  = page.to_s
    response.headers['Per-Page']      = per_page.to_s
    response.headers['Total-Entries'] = @count.to_s

    respond_to do |format|
      format.json { render :json => {:organizations => @organizations.map{|o| o.as_json(:only => only, :methods => methods)}}, :callback => params[:callback] }
    end
  end
end
