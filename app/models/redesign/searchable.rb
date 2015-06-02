class Redesign::Searchable < ActiveRecord::Base

  class << self

    attr_accessor :searchable_map

    def index_all
      log = Logger.new(STDOUT)
      log.info "starting Redesign::Searchable.index_all"
      searchables.each do |searchable|
        searchable.all.find_in_batches.each_with_index do |group, batch|
          log.info "Processing batch ##{batch}"
          group.each do |model|
            import(searchable.new(model))
          end
        end
      end
      log.info "done indexing all the searchables."
    end

    def index_new_or_updated(cutoff = nil)
      cutoff ||= maximum(:last_indexed_at)
      searchables.each do |searchable|
        searchable.since(cutoff).each do |model|
          import(searchable.new(model))
        end
      end
    end

    def index(model)
      searchable = new_searchable(model)
      return if searchable.nil?

      if searchable.url_changed?
        if record = find_by(document_type: searchable.document_type,
                            url: searchable.url_was)
          record.update_attributes(searchable.attributes)
        end
      end
    end

    def remove(model)
      searchable = new_searchable(model)
      return if searchable.nil?

      where(document_type: searchable.document_type, url: searchable.url).destroy_all
    end

    private

    def new_searchable(model)
      if searchable_class = searchable_map[model.class]
        searchable_class.new(model)
      end
    end

    def import(searchable)
      searchable_model = self.where(url: searchable.url).first_or_initialize
      searchable_model.assign_attributes(searchable.attributes)
      searchable_model.last_indexed_at = Time.now
      searchable_model.save
      searchable_model
    end

    def searchables
      searchable_map.values
    end

    def searchable_map
      # TODO
      # Ideally classes that include Indexable would register themselves instead of
      # this hardcoded map
      @searchable_map ||= {
        CommunicationOnProgress => Redesign::Searchable::SearchableCommunicationOnProgress,
        Redesign::Container => Redesign::Searchable::SearchableContainer,
        Headline => Redesign::Searchable::SearchableHeadline,
        Organization => Redesign::Searchable::SearchableOrganization,
        Resource => Redesign::Searchable::SearchableResource,
        Event => Redesign::Searchable::SearchableEvent,
      }
    end

  end

end
