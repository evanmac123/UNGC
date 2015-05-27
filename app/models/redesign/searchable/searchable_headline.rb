module Redesign::Searchable::SearchableHeadline
  def index_headline(headline)
    title = headline.title
    country = headline.country.try(:name)
    description = with_helper { strip_tags(headline.description) }
    content = "#{headline.location}\n#{country}#{description}"
    url = headline_url(headline)
    import 'Headline', url: url, title: title, content: content, meta: headline_tags(headline)
  end

  def headline_tags(headline)
    (headline.issues.map(&:name) +
    headline.topics.map(&:name) +
    headline.sectors.map(&:name)).
    join(' ')
  end

  def index_headlines
    Headline.approved.each { |h| index_headline h }
  end

  def index_headlines_since(time)
    Headline.approved.where(new_or_updated_since(time)).each { |h| index_headline h }
  end

  def remove_headline(headline)
    remove 'Headline', headline_url(headline)
  end

  def headline_url(headline)
    with_helper { redesign_news_path(headline) }
  end
end

