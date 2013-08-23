module Searchable::SearchableHeadline
  def index_headline(headline)
    title = headline.title
    country = headline.country.try(:name)
    description = with_helper { strip_tags(headline.description) }
    content = "#{headline.location}\n#{country}#{description}"
    url = with_helper { headline_path(headline) }
    import 'Headline', url: url, title: title, content: content, object: headline
  end

  def index_headlines
    Headline.approved.each { |h| index_headline h }
  end

  def index_headlines_since(time)
    Headline.approved.find(:all, conditions: new_or_updated_since(time)).each { |h| index_headline h }
  end
end
