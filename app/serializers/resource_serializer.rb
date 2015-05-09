class ResourceSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:id] = object.id
    h[:title] = object.title
    h
  end
end
