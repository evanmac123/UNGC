module Searchable::SearchableOrganization
  def index_organization(organization)
    title   = organization.name
    content = ''
    url     = with_helper { participant_path(organization) }
    import 'Participant', url: url, title: title, content: content, object: organization
  end
  
  def index_organizations
    Organization.participants.approved.each { |o| index_organization o }
  end
end