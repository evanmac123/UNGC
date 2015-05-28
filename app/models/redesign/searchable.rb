class Redesign::Searchable < ActiveRecord::Base

  class << self

    attr_accessor :searchable_map

    def index_all
      searchables.each do |searchable|
        searchable.all.each do |model|
          import(searchable.new(model))
        end
      end
    end

    def index_since(cutoff)
      searchables.each do |searchable|
        searchable.since(cutoff).each do |model|
          import(searchable.new(model))
        end
      end
    end

    def remove(model)
      searchable = new_searchable(model)
      where(document_type: searchable.document_type, url: searchable.url).destroy_all
    end

    private

    def new_searchable(model)
      searchable_class = searchable_map.fetch(model.class)
      searchable_class.new(model)
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
