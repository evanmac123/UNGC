class Redesign::Container < ActiveRecord::Base
  enum kind: [
    :home
  ]

  belongs_to :public_payload, class_name: 'Redesign::Payload'
  belongs_to :draft_payload, class_name: 'Redesign::Payload'

  has_many :payloads, class_name: 'Redesign::Payload'

  def self.normalize_slug(raw)
    '/' + raw.to_s.downcase.strip.sub(/\A\/|\Z\//, '')
  end

  def self.lookup(kind, slug = '/')
    where(kind: self.kinds[kind], slug: normalize_slug(slug)).
      includes(:public_payload, :draft_payload).
      first
  end

  def slug=(raw)
    write_attribute :slug, Redesign::Container.normalize_slug(raw)
  end
end
