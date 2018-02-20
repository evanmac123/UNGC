# frozen_string_literal: true

class Crm::Adapters::Base
  attr_reader :model, :changes, :transform_action
  attr_accessor :crm_params

  def initialize(model, action, changes={})
    @model = model
    @transform_action = action
    @changes = changes || {}
    @crm_params = {}
  end

  def crm_payload(foreign_keys={})
    build_crm_payload
    foreign_keys.blank? ? crm_params : crm_params.merge(foreign_keys)
  end

  protected

  def text(input, length = nil)
    length ? input&.truncate(length) : input
  end

  def picklist(input)
    a = *input
    a.join(";")
  end

  def self.convert_id(rails_id)
    rails_id
  end

  def changed?(attribute)
    transform_action == :create || (changes[attribute] && changes[attribute][0] != changes[attribute][1])
  end

  def column(crm_key, attribute = nil, has_changed = false)
    return unless has_changed || (attribute && changed?(attribute))

    value = block_given? ? yield(model) : model.public_send(attribute)
    crm_params[crm_key] = coerce(value)
  end

  def relation_changed?(relation)
    model.public_send(relation).collect(&:id).sort != model.public_send(relation).pluck(&:id).sort
  end

  def build_crm_payload
    {}
  end

  def coerce(value)
    case value
      when Numeric, String, NilClass
        value
      when TrueClass
        true
      when FalseClass
        false
      when ActiveSupport::TimeWithZone
        # YYYY-MM-DDThh:mm:ss.sssZ
        value.strftime("%Y-%m-%dT%H:%M:%S.%LZ")
      when Date
        # YYYY-MM-DD
        value.strftime("%F")
      when Hash
        value.transform_values { |v| coerce(v) }
      else
        raise "Unexpected type: #{value.class}"
    end
  end
end
