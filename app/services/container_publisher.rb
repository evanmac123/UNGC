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
      container.update!(
        public_payload_id: draft.copy.id
      )
    end

    true
  end
end
