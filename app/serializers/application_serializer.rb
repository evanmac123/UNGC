class ApplicationSerializer
  include Rails.application.routes.url_helpers

  attr_reader :object, :options, :router

  def self.wrap(objects)
    objects.map do |o|
      self.new(o).as_json
    end
  end

  def initialize(object, options = {})
    @object  = object
    @options = options
    @include = (@options[:include] || []).map(&:to_sym)
    @router  = Rails.application.routes.url_helpers
  end

  def include?(link)
    @include.include?(link.to_sym)
  end

  def attributes
    { id:   object.id,
      type: object.class.to_s.demodulize.underscore }
  end

  def as_json(*args)
    attributes
  end
end
