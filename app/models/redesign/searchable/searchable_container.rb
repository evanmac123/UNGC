class Redesign::Searchable::SearchableContainer < Redesign::Searchable::Base
  alias_method :container, :model

  def self.all
    Redesign::Container.published
  end

  def document_type
    'Container'
  end

  def title
    page = ContainerPage.new(container, container.payload.data)
    page.meta_title
  end

  def url
    remove_redesign_prefix container.path
  end

  def url_was
    remove_redesign_prefix container.path_was
  end

  def url_changed?
    container.path_changed?
  end

  def content
    strip_tags extract_values(container.payload.data).reject(&:blank?).join(' ')
  end

  def meta
    container.taggings.map(&:content).join(' ')
  end

  private

  def extract_values(input)
    case
    when input.is_a?(Hash)
      input.flat_map do |k, v|
        extract_values(v)
      end
    when input.is_a?(Array)
      input.flat_map do |v|
        extract_values(v)
      end
    else
      input.to_s
    end
  end

end
