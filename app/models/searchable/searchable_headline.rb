module Searchable::SearchableHeadline
  def index_headline(headline)
    title = headline.title
    content = headline.location + "\n" + 
      headline.country.try(:name) + 
      with_helper { strip_tags(headline.description) }
    url = with_helper { headline_path(headline) }
    import 'Headline', url: url, title: title, content: content, object: headline
  end
  
  def index_headlines
    Headline.approved.each { |h| index_headline h }
  end
end