namespace :data do

  desc "rename LocalNetwork states"
  task rename_local_network_states: :environment do
    LocalNetwork.transaction do
      puts LocalNetwork.where(state: 'Established').update_all(state: 'Active')
      puts LocalNetwork.where(state: 'Formal').update_all(state: 'Advanced')
    end
  end

  task backfill_searchables_with_delisted_organizations: :environment do
    searchable = Searchable::SearchableOrganization
    inactive = searchable.all.where.not(active: true)
    Searchable.index_searchable(searchable, inactive)
  end

end
