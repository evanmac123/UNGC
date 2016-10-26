namespace :organization do

  desc "Remove stale searchables"
  task clear_stale_searchables: :environment do
    Sweeper.new.go
  end

  class Sweeper
    include Rails.application.routes.url_helpers

    def go
      ids = Searchable::SearchableOrganization.all.ids
      urls = ids.map do |id|
        participant_path(id)
      end
      puts urls.count
      puts Searchable.where.not(url: urls).count
    end

  end

end
