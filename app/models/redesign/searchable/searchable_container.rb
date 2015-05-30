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
    container.path
  end

  def url_was
    container.path_was
  end

  def url_changed?
    container.path_changed?
  end

  def content
    strip_tags extract_values(container.payload.data).reject(&:blank?).join(' ')
  end

  def meta
    container.taggings.map(&:content)
  end

  private

  def extract_values(input)
    input.flat_map do |k, v|
      case
      when v.respond_to?(:flat_map)
        extract_values v
      when v.present?
        v.to_s
      else
        k.to_s
      end
    end
  end

end
