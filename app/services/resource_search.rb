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
      order: (order || 'year desc')
    }

    options[:per_page] = 100 if options[:per_page] > 100
    options[:with] ||= {}

    filter_options_for_author(options) if author.present?

    filter_options_for_topics(options) if topic

    filter_options_for_language(options) if language.present?

    @key = keyword.force_encoding("UTF-8") if keyword.present?

    options.delete(:with) if options[:with] == {}


    @results = Resource.search @key || '', options
    raise Riddle::ConnectionError unless @results && @results.total_entries
    @options = options
    @results
  end
  
  def topic_ids
    @topic_ids = topic[:principle_ids].map(&:to_i) rescue []
  end
  
  def author_ids
    @options[:with][:authors_ids] rescue []
  end
  
  def language_ids
    @options[:with][:language_ids] rescue []
  end
    
  def results_description
    
    if topic_ids.present?
      topics = Principle.find(topic_ids).map(&:name)
      topics = ' covering ' + topics.to_sentence(:last_word_connector => ' or ')
    else
      topics = ''
    end
    
    if author_ids.present?
      authors = Author.find(author_ids).map(&:full_name)
      authors = ' authored by ' + authors.to_sentence(:last_word_connector => ' or ')
    else
      authors = ''
    end
    
    if language_ids.present?
      languages = Language.find(language_ids).map(&:name)
      languages = ' available in ' + languages.to_sentence(:last_word_connector => ' or ')
    else
      languages = ''
    end
    
    @results_description = ''
    @results_description = ' matching ' + "\"#{@key}\"" if @key.present?
    @results_description += languages
    @results_description += topics
    @results_description += authors
    @results_description += '.'
    
  end

  private

    def filter_options_for_author(options)
      options[:with].merge!(authors_ids: author.map { |i| i.to_i })
    end

    def filter_options_for_topics(options)
      options[:with].merge!(principle_ids: topic[:principle_ids].map { |i| i.to_i })
    end

    def filter_options_for_language(options)
      options[:with].merge!(language_ids: language.map { |i| i.to_i })
    end
end
