# == Schema Information
#
# Table name: searchables
#
#  id              :integer          not null, primary key
#  last_indexed_at :datetime
#  url             :string(255)
#  document_type   :string(255)
#  title           :text(65535)
#  content         :text(65535)
#  meta            :text(65535)
#  created_at      :datetime
#  updated_at      :datetime
#

class Searchable < ActiveRecord::Base

  class << self

    attr_accessor :searchable_map

    def index_all
      log.info "starting Searchable.index_all"

      searchables.each do |searchable|
        index_searchable(searchable)
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

    def index_searchable(searchable, searchable_scope = nil)
      searchable_scope ||= searchable.all
      searchable_scope.find_in_batches(batch_size: batch_size).each_with_index do |group, batch|
        break if stop_before?(batch)

        log.info "Processing batch ##{batch}"
        group.each do |model|
          import(searchable.new(model))
        end
      end
    end

    def index(model)
      import(new_searchable(model))
    end

    def update_url(model)
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
    rescue ActiveRecord::StatementInvalid => e
      log.error "INVALID SEARCHABLE ID: #{searchable.model.id}"
      log.error e.to_s
    end

    def searchables
      searchable_map.values
    end

    def searchable_map
      # TODO
      # Ideally classes that include Indexable would register themselves instead of
      # this hardcoded map
      @searchable_map ||= {
        CommunicationOnProgress => Searchable::SearchableCommunicationOnProgress,
        Container => Searchable::SearchableContainer,
        Headline => Searchable::SearchableHeadline,
        Organization => Searchable::SearchableOrganization,
        Resource => Searchable::SearchableResource,
        Event => Searchable::SearchableEvent,
      }
    end

    def batch_size
      if Rails.env.production? then 1000 else 10 end
    end

    def stop_before?(batch)
      Rails.env.production? == false && batch > 0
    end

    def log
      @log ||= if Rails.env.production?
        Logger.new(STDOUT)
      else
        Rails.logger
      end
    end

  end

end
