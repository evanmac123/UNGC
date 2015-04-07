class ContainerPublisher
  attr_accessor :container, :draft, :published

  def initialize(container)
    self.container = container
    self.draft     = container.draft_payload
    self.published = container.public_payload
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
      update_tags
    end

    true
  end

  private

  def update_payload
    container.update!(
      public_payload_id: draft.copy.id
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
        .where("#{tag_type}_id not in (?)", ids)
        .destroy_all
    end
  end

  def to_domain_type(input)
    input.to_s.singularize.gsub(/[^a-z]/, '')
  end
end
