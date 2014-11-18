require 'zlib'

class ParticipantsController < ApplicationController
  helper :cops, :pages, 'admin/cops'
  before_filter :determine_navigation
  before_filter :find_participant, :only => [:show]

  def show
  end

  def search
    if params[:commit].present? # NOTE: keys off of the submit button - since keyword can be blank
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
      options = {
        per_page: (params[:per_page] || 10).to_i,
        page: (params[:page] || 1).to_i,
        star: true
      }

      options[:per_page] = 100 if options[:per_page] > 100
      #options[:sort_mode] = :extended
      options[:order] = params[:sort_by] || "joined_on"
      options[:order] += ' ' + (params[:direction] || 'DESC')
      options[:with] ||= {}
      filter_options_for_country(options) if params[:country]
      filter_options_for_joined_on(options) if params[:joined_after] && params[:joined_before]
      filter_options_for_business_type(options) if params[:business_type]
      filter_options_for_sector(options)
      filter_options_for_listing_status(options) if params[:listing_status_id]
      filter_options_for_is_ft_500(options) if params[:is_ft_500]

      keyword = params[:keyword].force_encoding("UTF-8") if params[:keyword].present?

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword => keyword)
      options.delete(:with) if options[:with] == {}
      # logger.info " ** Participant search with options: #{options.inspect}"
      @results = Organization.participants_only.search keyword || '', options
      raise Riddle::ConnectionError unless @results && @results.total_entries
      render :action => 'index'
    end

    def filter_options_for_country(options)
      options[:with].merge!(country_id: params[:country].map { |i| i.to_i })
    end

    def filter_options_for_business_type(options)
      business_type_selected = if params[:business_type] != 'all'
        params[:business_type].to_i
      else
        :all # all if it's nil or 'all'
      end

      # we don't need to set this if it's all
      unless business_type_selected == :all
        options[:with].merge!(business: business_type_selected)
      end

      if business_type_selected == OrganizationType::BUSINESS
        cop_status = params[:cop_status]
        skip_cop_status = cop_status.blank? || cop_status == 'all'
        unless skip_cop_status
          # http://pat.github.io/thinking-sphinx/common_issues.html#string_filters
          state_hash = Zlib.crc32(cop_status)
          options[:with].merge!(cop_state: state_hash)
        end
      elsif business_type_selected == OrganizationType::NON_BUSINESS
        options[:with].merge!(organization_type_id: params[:organization_type_id].to_i) unless params[:organization_type_id].blank?
      end
    end

    def filter_options_for_sector(options)
      options[:with].merge!(sector_id: params[:sector_id].to_i) if params[:sector_id].present?
    end

    def filter_options_for_listing_status(options)
      options[:with].merge!(listing_status_id: params[:listing_status_id].to_i) if params[:listing_status_id] != 'all'
    end

    def filter_options_for_is_ft_500(options)
      options[:with].merge!(is_ft_500: params[:is_ft_500].to_i) if params[:is_ft_500] != ''
    end

    def filter_options_for_joined_on(options)
      # check that date_from_params returns a valid date
      if params[:joined_after] != "" && params[:joined_before] != ""
        options[:with].merge!(joined_on: date_from_params(:joined_after)..date_from_params(:joined_before))
      end
    end

    def date_from_params(param_name)
      Time.parse params[param_name]
    end

end
