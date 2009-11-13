class ParticipantsController < ApplicationController
  helper :cops, :pages
  before_filter :determine_navigation
  before_filter :find_participant, :only => [:show]
  
  def show
  end

  def search
    unless params[:commit].blank? # NOTE: keys off of the submit button - since keyword can be blank
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
      business_type_selected = params[:business_type] == 'all' ? :all : params[:business_type].to_i
      options[:with].merge!(business: business_type_selected) if params[:business_type] unless business_type_selected == :all
      if business_type_selected == OrganizationType::BUSINESS
        options[:with].merge!(cop_status: business_type_selected) if params[:cop_status] unless params[:cop_status] == 'all'
      elsif business_type_selected == OrganizationType::NON_BUSINESS
        options[:with].merge!(organization_type_id: params[:organization_type_id].to_i) unless params[:organization_type_id].blank?
      end
      @searched_for = options[:with].merge(:keyword => params[:keyword])
      options.delete(:with) if options[:with] == {}
      logger.info " ** #{options.inspect}"
      @results = Organization.search params[:keyword] || '', options
      render :action => 'index'
    end
end
