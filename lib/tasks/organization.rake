namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    sweeper = Searchable::StaleOrganizationSweeper.new
    sweeper.update_or_evict_stale_organizations
  end

end
