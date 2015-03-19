class ContainerSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:slug]              = object.slug || '/'
    h[:layout]            = object.layout
    h[:public_payload_id] = object.public_payload_id
    h[:draft_payload_id]  = object.draft_payload_id
    h
  end
end
