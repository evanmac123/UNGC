class ParticipantsController < ApplicationController
  helper :cops, :pages
  before_filter :determine_navigation
  before_filter :find_participant, :only => [:show]
  
  def show
  end

  def search
    unless params[:keyword].blank?
      results_for_search
    else
      show_search_form
    end
  end

  private
    def default_navigation
      DEFAULTS[:participant_search_path]
    end

    def find_participant
      if params[:id] =~ /\A[0-9]+\Z/ # it's all numbers
        @participant = Organization.find_by_id(params[:id])
      else
        @participant = Organization.find_by_param(params[:id])
      end
      redirect_to root_path unless @participant # FIXME: Should redirect to search?
    end

    def show_search_form
      render :action => 'search_form'
    end
    
    def results_for_search
      options = {per_page: (params[:per_page] || 10).to_i, page: (params[:page] || 1).to_i}
      options[:with] ||= {}
      options[:with].merge!(country_id: params[:country].map { |i| i.to_i }) if params[:country]
      options[:with].merge!(business: params[:business_type].to_i) if params[:business_type] unless params[:business_type] == 'all'
      options[:with].merge!(cop_status: params[:cop_status].to_i) if params[:cop_status] unless params[:cop_status] == 'all'
      options.delete(:with) if options[:with] == {}
      logger.info " ** #{options.inspect}"
      @results = Organization.search params[:keyword], options
      render :action => 'index'
    end
end
