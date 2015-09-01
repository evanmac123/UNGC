class TaggingSerializer < ApplicationSerializer
  def attributes
    h = {}
    h[:id] = object.id
    h[:name] = name
    h
  end
  private

  def name
    if object.is_parent?
      "PARENT: #{object.name}"
    else
      object.name
    end
  end
end
