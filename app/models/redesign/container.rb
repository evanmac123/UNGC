class Redesign::Container < ActiveRecord::Base
  enum layout: [
    :home,
    :landing,
    :article,
  ]

  belongs_to :public_payload, class_name: 'Redesign::Payload'
  belongs_to :draft_payload, class_name: 'Redesign::Payload'

  has_many :payloads, class_name: 'Redesign::Payload'

  after_save :update_draft_payload

  validate :validate_draft_payload

  def self.normalize_slug(raw)
    '/' + raw.to_s.downcase.strip.sub(/\A\/|\Z\//, '')
  end

  def self.lookup(layout, slug = '/')
    where(layout: layouts[layout], slug: normalize_slug(slug)).
      includes(:public_payload, :draft_payload).
      first
  end

  def slug=(raw)
    write_attribute :slug, Redesign::Container.normalize_slug(raw)
  end

  def data=(raw_draft_data)
    payload_data = "#{layout.to_s.classify}Layout".constantize.new(raw_draft_data)

    if payload_data.valid?
      @draft_payload_data = payload_data.as_json
    else
      @draft_payload_errors = payload_data.errors
    end
  end

  def payload(draft = false)
    if draft
      draft_payload
    else
      public_payload
    end
  end

  protected

  def update_draft_payload
    return true unless @draft_payload_data

    if draft_payload
      draft_payload.update(data: @draft_payload_data)
    else
      update(draft_payload: payloads.create!(data: @draft_payload_data))
    end
  end

  def validate_draft_payload
    return true unless @draft_payload_errors
    errors.add :data, 'is not a valid payload'
  end

end
