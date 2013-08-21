FakePage = Struct.new(:html_code, :title, :path)

class ResourcesController < ApplicationController

  def search
    @leftnav_selected = FakePage.new('resources','About Us','resources')
    @subnav_selected = FakePage.new('search','Tools And Resources','search')
    if params[:keyword].blank?
      show_search_form
    else
      results_for_search
    end
  end

  private

    def results_for_search
      get_search_results
      render :action => 'index'
    end

    def show_search_form
      render :action => 'search_form', layout: 'fullscreen'
    end

    def get_search_results
      options = {
        per_page: (params[:per_page] || 10).to_i,
        page: (params[:page] || 1).to_i,
        star: true
      }

      options[:per_page] = 100 if options[:per_page] > 100
      options[:with] ||= {}

      keyword = params[:keyword].force_encoding("UTF-8") if params[:keyword].present?

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword => keyword)
      options.delete(:with) if options[:with] == {}
      logger.info " ** Resource search with options: #{options.inspect}"

      @results = Resource.search keyword || '', options
      raise Riddle::ConnectionError unless @results && @results.total_entries
    end

end
