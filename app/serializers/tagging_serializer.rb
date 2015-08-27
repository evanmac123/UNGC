class TaggingSerializer < ApplicationSerializer
  def attributes
    h = {}
    h[:id] = object.id
    h[:name] = name
    h
  end
  private

  def name
    if object.parent?
      "PARENT: #{object.name}"
    else
      object.name
    end
  end
end
