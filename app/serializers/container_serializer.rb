class ContainerSerializer < ApplicationSerializer
  def attributes
    h = super
    h[:slug]                   = object.slug || '/'
    h[:depth]                  = object.depth
    h[:layout]                 = object.layout
    h[:parent_container_id]    = object.parent_container_id
    h[:public_payload_id]      = object.public_payload_id
    h[:draft_payload_id]       = object.draft_payload_id
    h[:child_containers_count] = object.child_containers_count

    if (payload = object.draft_payload)
      h[:data] = payload.data
    end

    case
    when object.path.present?
      h[:public_path] = object.path
    when object.home?
      h[:public_path] = router.redesign_root_path
    when object.article?
      h[:public_path] = router.redesign_article_path # XXX needs update
    when object.landing?
      h[:public_path] = router.redesign_landing_page_path # XXX needs update
    end

    h
  end
end
