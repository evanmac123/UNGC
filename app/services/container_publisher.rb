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
      ids.each do |id|
        params = {redesign_container_id: @container.id}
        params[tag_type] = id
        Tagging.where(params).first_or_create!
      end

      Tagging
        .where(redesign_container_id: @container.id)
        .where("#{tag_type}_id is not NULL")
        .where.not("#{tag_type}_id" => ids)
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
    input.to_s.singularize.gsub(/[^a-z]/, '')
  end
end
