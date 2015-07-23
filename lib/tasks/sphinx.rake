namespace :ts do

  desc "Rebuild the sphinx index using god to start and stop the index daemon"
  task rebuild_with_god: [:environment] do
    system 'sudo god stop unglobalcompact-sphinx'
    Rake::Task["ts:clear"].invoke
    Rake::Task["ts:reindex"].invoke
    system 'sudo god start unglobalcompact-sphinx'
  end

  desc "Reindex sphinx indexes, clearing the facets cache"
  task reindex: [:environment] do
    cache = Redesign::FacetCache.new(Redis.new)
    cache.clear
    Rake::Task["ts:index"].invoke
  end

end
