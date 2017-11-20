namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    sweeper = Searchable::StaleOrganizationSweeper.new
    sweeper.update_or_evict_stale_organizations
  end

  task missing_bracketed_revenue: :environment do
    Organization::RevenueMismatch.new.missing_bracketed_revenue
  end

  task joined_since_precise_revenue: :environment do
    Organization::RevenueMismatch.new.joined_since_precise_revenue
  end

  task updated_since_precise_revenue: :environment do
    Organization::RevenueMismatch.new.updated_since_precise_revenue
  end

  task revenue_mismatch: :environment do
    Organization::RevenueMismatch.new.revenue_mismatch
  end

end
