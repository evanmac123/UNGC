class Redesign::Searchable::SearchableHeadline < Redesign::Searchable::Base
  alias_method :headline, :model

  def self.all
    Headline.approved
  end

  def document_type
    'Headline'
  end

  def title
    headline.title
  end

  def url
    news_path(headline)
  end

  def content
    country = headline.country.try(:name)
    description = strip_tags(headline.description)
    content = "#{headline.location}\n#{country}#{description}"
  end

  def meta
    headline.taggings.map(&:content).join(' ')
  end

end
