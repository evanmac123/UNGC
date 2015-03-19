class ApplicationSerializer
  attr_reader :object

  def initialize(object)
    @object = object
  end

  def attributes
    { id:   object.id,
      type: object.class.to_s.demodulize.underscore }
  end

  def as_json(*args)
    attributes
  end
end
