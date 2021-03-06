namespace :search do

  desc "Rebuild the search index, clearing the facets cache, starting and stopping using god. Meant for production"
  task rebuild_with_god: [:environment] do
    system 'sudo god stop unglobalcompact-sphinx'
    Rake::Task["ts:clear"].invoke
    Rake::Task["ts:index"].invoke
    system 'sudo god start unglobalcompact-sphinx'
    FacetCache.clear
  end

  desc "Rebuild the search index, clearing the facets cache, starting and stopping the indexer. Meant for development."
  task rebuild: [:environment] do
    Rake::Task["ts:rebuild"].invoke
    FacetCache.clear
  end

  desc "Run the search indexer, clearing the facets cache. Does not stop the indexer."
  task index: [:environment] do
    Rake::Task["ts:index"].invoke
    FacetCache.clear
  end

end
