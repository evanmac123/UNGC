class Searchable::Base
  include ActionView::Helpers::SanitizeHelper
  include Rails.application.routes.url_helpers

  attr_reader :model

  def self.all
    raise 'must be implemented'
  end

  def self.since(cutoff)
    self.all.where(["(created_at > ?) OR (updated_at > ?)", cutoff, cutoff])
  end

  def initialize(model)
    @model = model
  end

  def url
    raise 'must implement'
  end

  def url_was
    raise 'must implement'
  end

  def url_changed?
    false
  end

  def document_type
    raise 'must implement'
  end

  def title
    ''
  end

  def content
    ''
  end

  def meta
    ''
  end

  def attributes
    Rails.logger.warn 'Stripping /redesign url prefixes'
    {
      url: url,
      document_type: document_type,
      title: title,
      content: content,
      meta: meta
    }
  end

  protected

  def remove_redesign_prefix(url)
    if url.present?
      url.sub(/^\/redesign/, '')
    else
      url
    end
  end

end
