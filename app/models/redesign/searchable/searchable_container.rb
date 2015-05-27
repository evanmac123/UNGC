class Redesign::Searchable::SearchableContainer < Redesign::Searchable::Base
  alias_method :container, :model

  def self.all
    Redesign::Container.where.not(public_payload_id: nil)
  end

  def document_type
    'Container'
  end

  def title
    container.payload.data.try(:meta_tags).try(:title)
  end

  def url
    container.path
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
      if v.respond_to? :flat_map
        extract_values v
      else
        v.to_s
      end
    end
  end

end
