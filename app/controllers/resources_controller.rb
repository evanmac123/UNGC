FakePage = Struct.new(:html_code, :title, :path)

class ResourcesController < ApplicationController

  def search
    @leftnav_selected = FakePage.new('resources','About Us','resources')
    @subnav_selected = FakePage.new('search','Tools And Resources','search')
    if params[:commit].blank?
      @authors = Author.scoped
      @topics = Principle.topics_menu
      @topic_ids = []
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

      filter_options_for_author(options) if params[:author].present?

      filter_options_for_topics(options) if params[:topic].present?

      filter_options_for_language(options) if params[:language].present?

      keyword = params[:keyword].force_encoding("UTF-8") if params[:keyword].present?

      # store what we searched_for so that the helper can pick it apart and make a pretty label
      @searched_for = options[:with].merge(:keyword => keyword)
      options.delete(:with) if options[:with] == {}
      logger.info " ** Resource search with options: #{options.inspect}"

      @results = Resource.approved_for_search.search keyword || '', options
      raise Riddle::ConnectionError unless @results && @results.total_entries
    end

    def filter_options_for_author(options)
      options[:with].merge!(authors_ids: params[:author].map { |i| i.to_i })
    end

    def filter_options_for_topics(options)
      options[:with].merge!(principle_ids: params[:topic][:principle_ids].map { |i| i.to_i })
    end

    def filter_options_for_language(options)
      options[:with].merge!(language_id: params[:language].to_i)
    end
end
