module Searchable::SearchableOrganization
  def index_organization(organization)
    title   = organization.name
    content = ''
    url     = with_helper { participant_path(organization) }
    import 'Participant', url: url, title: title, content: content, object: organization
  end

  def indexable_organizations
    Organization.participants.active.approved
  end

  def index_organizations
    indexable_organizations.each { |o| index_organization o }
  end

  def index_organizations_since(time)
    indexable_organizations.find(:all, conditions: new_or_updated_since(time)).each { |o| index_organization o }
  end

end
