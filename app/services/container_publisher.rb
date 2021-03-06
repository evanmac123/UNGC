class ContainerPublisher
  attr_accessor :container, :draft, :published, :contact

  def initialize(container, contact)
    self.container = container
    self.draft     = container.draft_payload
    self.published = container.public_payload
    self.contact = contact
  end

  def has_draft?
    draft ? true : false
  end

  def draft_json
    draft && draft.json_data
  end

  def published_json
    published && published.json_data
  end

  def no_changes?
    draft_json == published_json
  end

  def publish
    return false unless has_draft?
    return true if no_changes?

    container.transaction do
      update_payload
      update_content_type
      update_tags
    end

    true
  end

  def unpublish
    return false unless published

    container.transaction do
      # return the container to published status and unlink the public payload
      container.update!(
        has_draft: true,
        public_payload_id: nil
      )

      # content_type and tags follow the payload
      update_content_type
      update_tags

      # no longer return this container in search results
      Searchable.remove(container)
    end
  end

  private

  def update_payload
    payload = draft.copy
    payload.approve!(contact)
    container.update!(
      has_draft: false,
      public_payload_id: payload.id
    )
  end

  def update_tags
    # add any new tags and remove the old ones.
    draft.tags.each do |type, ids|
      tag_type = to_domain_type(type)
      tag_fk_id = "#{tag_type}_id"
      ids.each do |id|
        params = {container_id: @container.id}
        params[tag_fk_id] = id
        Tagging.where(params).first_or_create!
      end

      Tagging
        .where(container_id: @container.id)
        .where.not(tag_fk_id => nil)
        .where.not(tag_fk_id => ids)
        .destroy_all
    end
  end

  def update_content_type
    ct = draft.content_type
    return unless ct
    container.update!(
      content_type: ct
    )
  end

  def to_domain_type(input)
    input.to_s.singularize.gsub(/[^a-z_]/, '')
  end
end
