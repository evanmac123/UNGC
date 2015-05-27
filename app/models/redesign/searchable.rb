class Redesign::Searchable < ActiveRecord::Base

  class << self

    def index_all
      searchables.each do |searchable|
        # TODO remove this limit
        Rails.logger.warn '*** remove this take(5) ***'
        searchable.all.take(5).each do |model|
          import(searchable.new(model))
        end
      end
    end

    def index_since(cutoff)
      searchables.each do |searchable|
        models = searchable.all.where(changed_since(cutoff))
        models.each do |model|
          import(searchable.new(model))
        end
      end
    end

    def remove(model)
      searchable = searchable_map.fetch(model.class)
      instance = searchable.new(model)
      where(document_type: instance.document_type, url: instance.url).destroy_all
    end

    private

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
      @searchable_map ||= {
        CommunicationOnProgress => Redesign::Searchable::SearchableCommunicationOnProgress,
        Redesign::Container => Redesign::Searchable::SearchableContainer,
        Headline => Redesign::Searchable::SearchableHeadline,
        Organization => Redesign::Searchable::SearchableOrganization,
        Resource => Redesign::Searchable::SearchableResource,
      }
    end

  end

end
