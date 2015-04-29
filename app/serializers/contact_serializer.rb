class ContactSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:id] = object.id
    h[:name] = object.name
    h
  end
end
