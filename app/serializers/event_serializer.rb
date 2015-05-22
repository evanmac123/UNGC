class EventSerializer < ApplicationSerializer
  def attributes
    h = {}
    h[:id] = object.id
    h[:title] = object.title
    h
  end
end
