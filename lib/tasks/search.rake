namespace :search do
  desc "rebuild clearing the facets cache using god"
  task rebuild_with_god: [:environment] do
    system 'sudo god stop unglobalcompact-sphinx'
    Rake::Task["search:rebuild"].invoke
    system 'sudo god start unglobalcompact-sphinx'
  end

  desc "rebuild clearing the facets cache"
  task rebuild: [:environment] do
    cache = FacetCache.new(Redis.new)
    cache.clear
    Rake::Task["ts:clear"].invoke
    Rake::Task["ts:index"].invoke
  end

  desc "index clearing the facets cache"
  task index: [:environment] do
    cache = FacetCache.new(Redis.new)
    cache.clear
    Rake::Task["ts:index"].invoke
  end

end
