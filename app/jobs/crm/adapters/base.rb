# frozen_string_literal: true

class Crm::Adapters::Base
  attr_reader :model, :changes

  def initialize(model, changes={})
    @model = model
    @changes = changes
  end

  def transformed_crm_params(transform_action, foreign_keys={})
    result = to_crm_params(transform_action).transform_values { |value| coerce(value) }
    foreign_keys.blank? ? result : result.merge(foreign_keys)
  end

  def number(input, integer_precision = 18, fractional_precision = 0)
    # TODO: figure out what to do if the number exceeds the precision
    coerce(input)
  end

  def text(input, length = nil)
    if length
      coerce(input.try!(:truncate, length))
    else
      coerce(input)
    end
  end

  def phone(input)
    coerce(input.try!(:truncate, 40))
  end

  def fax(input)
    coerce(input.try!(:truncate, 40))
  end

  def picklist(input)
    coerce(Array.wrap(input).join(";"))
  end

  def email(input)
    coerce(input)
  end

  def postal_code(input)
    coerce(input.try!(:truncate, 20))
  end

  def self.convert_id(rails_id)
    rails_id
  end

  protected

  def to_crm_params(transform_action)
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
