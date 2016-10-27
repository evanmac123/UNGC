class Searchable::StaleOrganizationSweeper
  include Rails.application.routes.url_helpers

  # Find all Searchable Organizations which no longer meet
  # the requirements set-out in SearchableOrganization.all.
  # Evict them from the searchables table.
  #
  # Also remove any searchables that can't be tied back to
  # their Organizations
  def update_or_evict_stale_organizations
    ids = Searchable::SearchableOrganization.all.ids

    urls = ids.map do |id|
      participant_path(id)
    end

    stale_ids = Searchable.where(document_type: 'Participant').where.not(url: urls).map do |searchable|
      Integer(searchable.url.gsub('/what-is-gc/participants/', ''))
    end

    puts "Stale: #{stale_ids.count} / #{urls.count} total"

    # Reindex/evict Searchables
    valid_ids = Organization.where(id: stale_ids)
      .select(Searchable::SearchableOrganization::FIELDS)
      .map do |organization|
        organization.touch # will trigger a re-index / eviction
        organization.id
      end
    puts "Updated or evicted #{valid_ids.count} searchables"

    # Remove invalid Searchables
    invalid_ids = stale_ids - valid_ids
    invalid_urls = invalid_ids.map(&method(:participant_path))
    Searchable.where(url: invalid_urls).destroy_all
    puts "Removed #{invalid_urls.count} invalid searchables"
  end

end
