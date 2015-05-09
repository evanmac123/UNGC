class ContainerDraft
  attr_accessor :container, :contact

  def initialize(container, contact = nil)
    self.container = container
    self.contact = contact
  end

  def save(params)
    update = Redesign::Container.transaction do
      container.draft_payload.as_user(contact) if container.draft_payload.present?
      container.update(params)
    end
    container.update_attributes has_draft: true unless no_changes?
    update
  end

  private

  def no_changes?
    draft_json == published_json
  end

  def draft_json
    container.draft_payload.try(:json_data)
  end

  def published_json
    container.public_payload.try(:json_data)
  end

end
