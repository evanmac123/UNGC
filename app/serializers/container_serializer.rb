class ContainerSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:slug]              = object.slug || '/'
    h[:layout]            = object.layout
    h[:public_payload_id] = object.public_payload_id
    h[:draft_payload_id]  = object.draft_payload_id

    if (payload = object.draft_payload)
      h[:data] = payload.data
    end

    case
    when object.home?
      h[:public_path] = router.redesign_root_path
    end

    h
  end
end
