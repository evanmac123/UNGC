
desc "remove orphans and duplicated, index missing"
task prune_searchables: [
  :prune_communication_on_progresses,
  :prune_events,
  :prune_headlines,
  :prune_organizations,
  :prune_pages,
  :prune_resources
]

desc "prune CommunicationOnProgress"
task prune_communication_on_progresses: :environment do
  CommunicationOnProgressPruner.new.prune
end

desc "prune Event"
task prune_events: :environment do
  EventPruner.new.prune
end

desc "prune Headline"
task prune_headlines: :environment do
  HeadlinePruner.new.prune
end

desc "prune Organization"
task prune_organizations: :environment do
  OrganizationPruner.new.prune
end

desc "prune Page"
task prune_pages: :environment do
  PagePruner.new.prune
end

desc "prune Resource"
task prune_resources: :environment do
  ResourcePruner.new.prune
end

class Pruner
  include Rails.application.routes.url_helpers

  def prune
    puts document_type, ".oO -=-=-=-=-=-=-=- Oo."

    puts "\tgetting approved #{document_type}s"
    approved_models = Hash[approved.map {|h| [generate_url(h), h.id] }]

    puts "\tfinding orphans"
    orphaned = Searchable.where(document_type: document_type).where('url not in (?)', approved_models.keys)
    # orphaned.destroy_all

    # TODO add counts for each stage
    # look into pages and resources.

    puts "\tfinding indexed"
    indexed = Searchable.where(document_type: document_type).map(&:url)

    puts "\tfinding unindexed"
    unindexed = approved_models.reject { |url| indexed.include? url }

    puts "\tindexing missing #{document_type}s"
    unindexed.each do |url, id|
      puts "\t\tindexing #{url}"
      # index(id)
    end
  end

end

class CommunicationOnProgressPruner < Pruner
  def approved
    CommunicationOnProgress.approved.select(:id)
  end

  def generate_url(communication_on_progress)
    cop_detail_path(:id => communication_on_progress)
  end

  def document_type
    'CommunicationOnProgress'
  end

  def index(id)
    Searchable.index_communication_on_progress(CommunicationOnProgress.find(id))
  end

end

class EventPruner < Pruner
  def approved
    Event.approved.select([:id, :starts_on])
  end

  def generate_url(event)
    event_path(event)
  end

  def document_type
    'Event'
  end

  def index(id)
    Searchable.index_event(Event.find(id))
  end

end

class HeadlinePruner < Pruner

  def approved
    Headline.approved.select([:id, :published_on])
  end

  def generate_url(headline)
    headline_path(headline)
  end

  def document_type
    'Headline'
  end

  def index(id)
    Searchable.index_headline(Headline.find(id))
  end

end

class OrganizationPruner < Pruner
  def approved
    Organization.participants.active.approved.select(:id)
  end

  def generate_url(organization)
    participant_path(organization.id)
  end

  def document_type
    'Participant'
  end

  def index(id)
    Searchable.index_organization(Organization.find(id))
  end

end

class PagePruner < Pruner
  include ActionView::Helpers::SanitizeHelper

  def approved
    Page.approved
      .select([:id, :title, :content, :path])
      .where("title is not null and title <> ''")
      .where("dynamic_content = 1")
      .reject { |page| strip_tags(page.content).blank? }
  end

  def generate_url(page)
    page.path
  end

  def document_type
    'Page'
  end

  def index(id)
    Searchable.index_page(Page.find(id))
  end

end

class ResourcePruner < Pruner
  def approved
    Resource.approved.select(:id)
  end

  def generate_url(resource)
    Searchable.with_helper { resource_path(resource) }
  end

  def document_type
    'Resource'
  end

  def index(id)
    Searchable.index_resource(Resource.find(id))
  end

end
