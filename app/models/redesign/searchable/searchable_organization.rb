class Redesign::Searchable::SearchableOrganization < Redesign::Searchable::Base
  alias_method :organization, :model

  def self.all
    Organization.participants.active.approved
  end

  def document_type
    'Participant'
  end

  def title
    organization.name
  end

  def url
    remove_redesign_prefix redesign_participant_path(organization.id)
  end

  def content
    ''
  end

end
