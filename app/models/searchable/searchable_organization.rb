class Searchable::SearchableOrganization < Searchable::Base
  alias_method :organization, :model

  FIELDS = [:id, :name, :created_at, :updated_at]

  def self.all
    Organization.participants
      .approved
      .listed_and_publicly_delisted
      .select(FIELDS)
  end

  def document_type
    'Participant'
  end

  def title
    organization.name
  end

  def url
    remove_redesign_prefix participant_path(organization.id)
  end

  def content
    ''
  end

end
