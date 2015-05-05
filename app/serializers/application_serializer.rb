class ApplicationSerializer
  attr_reader :object, :options, :router

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
