require 'ostruct'

class ResourceSearch < OpenStruct
  def results
    @results ||= get_search_results
  end

  def get_search_results
    options = {
      per_page: (per_page || 10).to_i,
      page: (page || 1).to_i,
      star: true,
      order: (order || 'title asc')
    }

    options[:per_page] = 100 if options[:per_page] > 100
    options[:with] ||= {}

    filter_options_for_author(options) if author.present?

    filter_options_for_topics(options) if topic

    filter_options_for_language(options) if language.present?

    keyword = params[:keyword].force_encoding("UTF-8") if keyword

    options.delete(:with) if options[:with] == {}

    @results = Resource.search keyword || '', options
    raise Riddle::ConnectionError unless @results && @results.total_entries
    @results
  end

  def topic_ids
      @topic_ids = topic[:principle_ids].map(&:to_i) rescue []
  end

  private

    def filter_options_for_author(options)
      options[:with].merge!(authors_ids: author.map { |i| i.to_i })
    end

    def filter_options_for_topics(options)
      options[:with].merge!(principle_ids: topic[:principle_ids].map { |i| i.to_i })
    end

    def filter_options_for_language(options)
      options[:with].merge!(language_id: language.to_i)
    end
end
