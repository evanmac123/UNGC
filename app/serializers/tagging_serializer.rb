class TaggingSerializer < ApplicationSerializer
  def attributes
    h = {}
    h[:id] = object[0]
    h[:name] = object[1]
    h
  end
end
